import Foundation
import SwiftData

enum FoodSearchMode {
    case text
    case barcode
}

enum FoodSearchState {
    case idle
    case searching
    case results([FoodItem])
    case empty
    case error(String)
}

@Observable
final class FoodSearchViewModel {
    var query: String = ""
    var mode: FoodSearchMode = .text
    var searchState: FoodSearchState = .idle
    var scannedBarcode: String? = nil

    private let offService = OpenFoodFactsService()
    private let proxyService = FoodProxyService()
    private var searchTask: Task<Void, Never>?

    // MARK: - Text Search (debounced)

    func onQueryChanged(modelContext: ModelContext) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            searchState = .idle
            return
        }

        searchState = .searching
        searchTask = Task {
            // 400ms debounce
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }

            // Check local SwiftData cache first
            let cached = fetchCached(query: trimmed, modelContext: modelContext)
            if !cached.isEmpty {
                searchState = .results(cached)
            }

            // Then hit the backend for fresh results
            do {
                let results = try await proxyService.search(query: trimmed)
                guard !Task.isCancelled else { return }

                // Cache fresh results into SwiftData
                for item in results {
                    upsertFoodItem(item, modelContext: modelContext)
                }

                searchState = results.isEmpty ? .empty : .results(results)
            } catch {
                guard !Task.isCancelled else { return }
                if case .empty = searchState { } else if cached.isEmpty {
                    searchState = .error(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Barcode Scan

    func handleScannedBarcode(_ barcode: String, modelContext: ModelContext) {
        scannedBarcode = barcode
        searchState = .searching

        Task {
            // Check local cache by externalID first
            let descriptor = FetchDescriptor<FoodItem>(
                predicate: #Predicate { $0.externalID == barcode }
            )
            if let cached = try? modelContext.fetch(descriptor).first, !isStale(cached) {
                searchState = .results([cached])
                return
            }

            do {
                let item = try await offService.lookup(barcode: barcode)
                upsertFoodItem(item, modelContext: modelContext)
                searchState = .results([item])
            } catch APIError.notFound {
                searchState = .empty
            } catch {
                searchState = .error(error.localizedDescription)
            }
        }
    }

    func resetBarcode() {
        scannedBarcode = nil
        searchState = .idle
    }

    // MARK: - Helpers

    private func fetchCached(query: String, modelContext: ModelContext) -> [FoodItem] {
        let lower = query.lowercased()
        let descriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { $0.name.localizedStandardContains(lower) }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func upsertFoodItem(_ item: FoodItem, modelContext: ModelContext) {
        let externalID = item.externalID
        let descriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { $0.externalID == externalID }
        )
        if let existing = (try? modelContext.fetch(descriptor))?.first {
            // Update cached fields
            existing.name = item.name
            existing.caloriesPer100g = item.caloriesPer100g
            existing.proteinPer100g = item.proteinPer100g
            existing.carbohydratesPer100g = item.carbohydratesPer100g
            existing.fatPer100g = item.fatPer100g
            existing.cachedAt = Date()
        } else {
            modelContext.insert(item)
        }
    }

    private func isStale(_ item: FoodItem) -> Bool {
        let age = Date().timeIntervalSince(item.cachedAt)
        return age > FoodItemCacheTTL.days * 86_400
    }
}
