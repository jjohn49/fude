import SwiftUI
import SwiftData

private enum QuickTab: String, CaseIterable {
    case recent = "Recent"
    case favourites = "Favourites"
}

struct FoodSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// The meal name to pre-select in AddFoodEntryView (e.g. passed from FoodLogView).
    var preselectedMeal: String? = nil
    /// The date to log the entry against. Defaults to today.
    var targetDate: Date = Date()

    @State private var viewModel = FoodSearchViewModel()
    @State private var selectedItem: FoodItem? = nil
    @State private var quickTab: QuickTab = .recent

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode picker
                Picker("Mode", selection: $viewModel.mode) {
                    Label("Search", systemImage: "magnifyingglass").tag(FoodSearchMode.text)
                    Label("Scan", systemImage: "barcode.viewfinder").tag(FoodSearchMode.barcode)
                }
                .pickerStyle(.segmented)
                .tint(.fudeAccentPrimary)
                .padding()

                if viewModel.mode == .text {
                    textSearchContent
                } else {
                    barcodeContent
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TopBarTitle(text: "Add Food")
                }
                ToolbarItem(placement: .cancellationAction) {
                    TopBarTextButton(title: "Cancel") { dismiss() }
                }
            }
            .background(Color.fudeBackground)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
            .sheet(item: $selectedItem) { item in
                AddFoodEntryView(
                    foodItem: item,
                    targetDate: targetDate,
                    preselectedMeal: preselectedMeal
                ) {
                    dismiss()
                }
            }
            .onChange(of: viewModel.mode) { _, _ in
                viewModel.query = ""
                viewModel.searchState = .idle
                viewModel.resetBarcode()
            }
        }
    }

    // MARK: - Text Search

    @ViewBuilder
    private var textSearchContent: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField(text: $viewModel.query, prompt: Text("Search foods…").foregroundStyle(.secondary)) {
                    Text("Search foods…")
                }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .foregroundStyle(.primary)
                    .foregroundColor(.white)
                    .tint(.fudeAccentPrimary)
                    .submitLabel(.search)
                    .onChange(of: viewModel.query) { _, _ in
                        viewModel.onQueryChanged(modelContext: modelContext)
                    }
                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.query = ""
                        viewModel.searchState = .idle
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color.fudeSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            if viewModel.query.isEmpty {
                quickAccessContent
            } else {
                searchStateContent
            }
        }
    }

    // MARK: - Shared Food Row

    @ViewBuilder
    private func foodRow(_ item: FoodItem) -> some View {
        Button {
            selectedItem = item
        } label: {
            FoodSearchResultRow(item: item)
                .padding(12)
                .background(Color.fudeSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .padding(.horizontal, 12)
    }

    // MARK: - Quick Access (Recent / Favourites)

    @ViewBuilder
    private var quickAccessContent: some View {
        VStack(spacing: 0) {
            Picker("Quick Access", selection: $quickTab) {
                ForEach(QuickTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .tint(.fudeAccentPrimary)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            let items = quickFoods
            if items.isEmpty {
                quickEmptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(items, id: \.id) { foodRow($0) }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    @ViewBuilder
    private var quickEmptyState: some View {
        switch quickTab {
        case .recent:
            EmptyStateView(
                systemImage: "clock",
                title: "No recent foods",
                message: "Foods you log will appear here."
            )
        case .favourites:
            EmptyStateView(
                systemImage: "star",
                title: "No favourites yet",
                message: "Log a food 3+ times and it will appear here."
            )
        }
    }

    private var quickFoods: [FoodItem] {
        switch quickTab {
        case .recent:
            return viewModel.recentFoods(modelContext: modelContext)
        case .favourites:
            return viewModel.favouriteFoods(modelContext: modelContext)
        }
    }

    // MARK: - Search Results

    @ViewBuilder
    private var searchStateContent: some View {
        switch viewModel.searchState {
        case .idle:
            EmptyStateView(
                systemImage: "fork.knife.circle",
                title: "Search for a food",
                message: "Try \"chicken breast\", \"oats\", or \"banana\"."
            )

        case .searching:
            LoadingStateView(message: "Searching…")

        case .results(let items):
            let localCount = viewModel.localResultCount
            let showSections = localCount > 0 && items.count > localCount
            ScrollView {
                LazyVStack(spacing: 12) {
                    if showSections {
                        SectionHeader(title: "Your Foods").padding(.horizontal, 12)
                        ForEach(Array(items.prefix(localCount)), id: \.id) { foodRow($0) }
                        SectionHeader(title: "All Foods").padding(.horizontal, 12)
                        ForEach(Array(items.dropFirst(localCount)), id: \.id) { foodRow($0) }
                    } else {
                        ForEach(items, id: \.id) { foodRow($0) }
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 24)
            }

        case .empty:
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: "No results",
                message: "Try a different search term or scan a barcode."
            )

        case .error(let message):
            EmptyStateView(
                systemImage: "exclamationmark.triangle",
                title: "Search unavailable",
                message: message
            )
        }
    }

    // MARK: - Barcode Scanner

    @ViewBuilder
    private var barcodeContent: some View {
        if let barcode = viewModel.scannedBarcode {
            // Barcode scanned — show lookup result
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "barcode")
                        .foregroundStyle(.secondary)
                    Text(barcode)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Scan Again") {
                        viewModel.resetBarcode()
                    }
                    .font(.caption)
                }
                .padding(.horizontal)

                searchStateContent
            }
        } else {
            ZStack {
                BarcodeScannerAvailabilityView { scanned in
                    viewModel.handleScannedBarcode(scanned, modelContext: modelContext)
                }

                // Viewfinder overlay
                VStack {
                    Spacer()
                    Text("Point camera at a food barcode")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.5))
                        .clipShape(Capsule())
                        .padding(.bottom, 32)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
