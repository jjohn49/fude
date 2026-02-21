import SwiftUI
import SwiftData

struct FoodSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// The meal name to pre-select in AddFoodEntryView (e.g. passed from FoodLogView).
    var preselectedMeal: String? = nil

    @State private var viewModel = FoodSearchViewModel()
    @State private var selectedItem: FoodItem? = nil
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode picker
                Picker("Mode", selection: $viewModel.mode) {
                    Label("Search", systemImage: "magnifyingglass").tag(FoodSearchMode.text)
                    Label("Scan", systemImage: "barcode.viewfinder").tag(FoodSearchMode.barcode)
                }
                .pickerStyle(.segmented)
                .padding()

                if viewModel.mode == .text {
                    textSearchContent
                } else {
                    barcodeContent
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showDetail) {
                if let item = selectedItem {
                    AddFoodEntryView(
                        foodItem: item,
                        preselectedMeal: preselectedMeal
                    ) {
                        dismiss()
                    }
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
                TextField("Search foods…", text: $viewModel.query)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
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
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.bottom, 8)

            searchStateContent
        }
    }

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
            List(items, id: \.id) { item in
                Button {
                    selectedItem = item
                    showDetail = true
                } label: {
                    FoodSearchResultRow(item: item)
                }
                .foregroundStyle(.primary)
            }
            .listStyle(.plain)

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
