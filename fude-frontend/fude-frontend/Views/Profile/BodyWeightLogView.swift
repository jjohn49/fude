import SwiftUI
import SwiftData

struct BodyWeightLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \BodyWeightEntry.date, order: .reverse) private var entries: [BodyWeightEntry]

    @State private var weightText: String = ""
    @State private var note: String = ""
    @State private var showingForm = false

    private var latestWeight: BodyWeightEntry? { entries.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SectionHeader(title: "Latest")
                VStack(spacing: 8) {
                    if let latest = latestWeight {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Current")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(latest.weightKg.kgString)
                                    .font(.title2.bold().monospacedDigit())
                            }
                            Spacer()
                            Text(latest.date.shortFormatted)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    } else {
                        Text("No weight logged yet.")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                .background(Color.fudeSurface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 12)

                SectionHeader(title: "History")
                VStack(spacing: 10) {
                    ForEach(entries) { entry in
                        HStack {
                            Text(entry.weightKg.kgString)
                                .font(.subheadline.monospacedDigit())
                            if !entry.note.isEmpty {
                                Text("· \(entry.note)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(entry.date.shortFormatted)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteEntry(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(12)
                .background(Color.fudeSurface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 12)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.fudeBackground)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TopBarTitle(text: "Body Weight")
            }
                ToolbarItem(placement: .topBarTrailing) {
                    TopBarIconButton(systemImage: "plus", accessibilityLabel: "Log weight") {
                        showingForm = true
                    }
                }
            }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showingForm) {
            logWeightSheet
        }
    }

    // MARK: - Log Weight Sheet

    private var logWeightSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Weight")
                    VStack(spacing: 10) {
                        HStack {
                            TextField(text: $weightText, prompt: Text("e.g. 75.5").foregroundStyle(.secondary)) {
                                Text("e.g. 75.5")
                            }
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.primary)
                            .foregroundColor(.white)
                            Spacer()
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)

                    SectionHeader(title: "Note (Optional)")
                    VStack(spacing: 10) {
                        TextField(text: $note, prompt: Text("e.g. morning, post-workout").foregroundStyle(.secondary)) {
                            Text("e.g. morning, post-workout")
                        }
                        .foregroundStyle(.primary)
                        .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(Color.fudeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.fudeBackground)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TopBarTitle(text: "Log Weight")
                }
                ToolbarItem(placement: .cancellationAction) {
                    TopBarTextButton(title: "Cancel") {
                        clearForm()
                        showingForm = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    TopBarTextButton(title: "Save", systemImage: "checkmark") {
                        saveEntry()
                    }
                    .disabled(parsedWeight == nil)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private var parsedWeight: Double? {
        Double(weightText.replacingOccurrences(of: ",", with: "."))
    }

    private func saveEntry() {
        guard let kg = parsedWeight, kg > 0 else { return }
        let entry = BodyWeightEntry(weightKg: kg, note: note)
        modelContext.insert(entry)
        try? modelContext.save()
        clearForm()
        showingForm = false
    }

    private func clearForm() {
        weightText = ""
        note = ""
    }

    private func deleteEntry(_ entry: BodyWeightEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }
}

// MARK: - Double extension

private extension Double {
    var kgString: String { String(format: "%.1f kg", self) }
}

#Preview {
    NavigationStack {
        BodyWeightLogView()
    }
    .modelContainer(previewContainer())
}
