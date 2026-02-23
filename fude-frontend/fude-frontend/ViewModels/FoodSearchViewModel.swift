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
    /// Number of items at the front of the results array that came from the local SwiftData cache.
    /// Used by FoodSearchView to render a "Your Foods" section above network-only results.
    var localResultCount: Int = 0

    private let offService = OpenFoodFactsService()
    private let proxyService = FoodProxyService()
    private var searchTask: Task<Void, Never>?

    // MARK: - Text Search (debounced)

    func onQueryChanged(modelContext: ModelContext) {
        searchTask?.cancel()
        localResultCount = 0

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

            // 1. Show local SwiftData cache immediately
            let cached = fetchCached(query: trimmed, modelContext: modelContext)
            localResultCount = cached.count
            if !cached.isEmpty {
                searchState = .results(cached)
            }

            // 2. Fetch fresh results from backend
            do {
                let results = try await proxyService.search(query: trimmed)
                guard !Task.isCancelled else { return }

                // Cache fresh results into SwiftData
                for item in results {
                    upsertFoodItem(item, modelContext: modelContext)
                }

                // Merge: local items first, then network-only items (deduplicated by externalID)
                let localIDs = Set(cached.map { $0.externalID })
                let networkOnly = results.filter { !localIDs.contains($0.externalID) }
                let merged = cached + networkOnly

                localResultCount = cached.count  // preserved at front of merged array
                searchState = merged.isEmpty ? .empty : .results(merged)
            } catch {
                guard !Task.isCancelled else { return }
                // Keep showing local results if we have them; only show error if nothing to show
                if cached.isEmpty {
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

    // MARK: - Quick Access

    /// Returns up to 10 most-recently-logged unique FoodItems.
    func recentFoods(modelContext: ModelContext) -> [FoodItem] {
        var descriptor = FetchDescriptor<FoodEntry>(
            sortBy: [SortDescriptor(\.loggedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 50
        guard let entries = try? modelContext.fetch(descriptor) else { return [] }

        var seen = Set<PersistentIdentifier>()
        var result: [FoodItem] = []
        for entry in entries {
            guard let item = entry.foodItem else { continue }
            let pid = item.persistentModelID
            if seen.insert(pid).inserted {
                result.append(item)
                if result.count >= 10 { break }
            }
        }
        return result
    }

    /// Returns FoodItems logged 3+ times, sorted by frequency descending.
    func favouriteFoods(modelContext: ModelContext) -> [FoodItem] {
        let descriptor = FetchDescriptor<FoodEntry>()
        guard let entries = try? modelContext.fetch(descriptor) else { return [] }

        var frequency: [PersistentIdentifier: (FoodItem, Int)] = [:]
        for entry in entries {
            guard let item = entry.foodItem else { continue }
            let pid = item.persistentModelID
            if let existing = frequency[pid] {
                frequency[pid] = (existing.0, existing.1 + 1)
            } else {
                frequency[pid] = (item, 1)
            }
        }

        return frequency.values
            .filter { $0.1 >= 3 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
}
