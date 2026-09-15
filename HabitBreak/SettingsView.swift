import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Quote.createdAt) private var quotes: [Quote]
    @Query(sort: \HelpStep.sortOrder) private var steps: [HelpStep]
    @State private var newQuote = ""
    @State private var newStep = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Help checklist") {
                    ForEach(steps) { step in Text(step.title) }
                    .onDelete(perform: deleteSteps)
                    .onMove(perform: moveSteps)
                    HStack {
                        TextField("Add a step", text: $newStep)
                        Button("Add", action: addStep).disabled(trimmedStep.isEmpty)
                    }
                }

                Section {
                    ForEach(quotes) { quote in Text("“\(quote.text)”") }
                    .onDelete(perform: deleteQuotes)
                    if quotes.count < 10 {
                        VStack(alignment: .trailing) {
                            TextField("Add a quote", text: $newQuote, axis: .vertical)
                                .lineLimit(2...4)
                            Button("Add quote", action: addQuote).disabled(trimmedQuote.isEmpty)
                        }
                    }
                } header: {
                    Text("Quotes")
                } footer: {
                    Text("\(quotes.count) of 10 quotes")
                }

                Section("Privacy") {
                    Label("Data stays on this device", systemImage: "lock")
                }
            }
            .navigationTitle("Settings")
            .environment(\.editMode, .constant(.active))
        }
    }

    private var trimmedStep: String { newStep.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedQuote: String { newQuote.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func addStep() {
        guard !trimmedStep.isEmpty else { return }
        modelContext.insert(HelpStep(title: trimmedStep, sortOrder: (steps.map(\.sortOrder).max() ?? -1) + 1))
        newStep = ""
    }

    private func addQuote() {
        guard quotes.count < 10, !trimmedQuote.isEmpty else { return }
        modelContext.insert(Quote(text: trimmedQuote))
        newQuote = ""
    }

    private func deleteSteps(at offsets: IndexSet) {
        offsets.map { steps[$0] }.forEach(modelContext.delete)
        normalizeStepOrder()
    }

    private func moveSteps(from source: IndexSet, to destination: Int) {
        var reordered = steps
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, step) in reordered.enumerated() { step.sortOrder = index }
    }

    private func normalizeStepOrder() {
        for (index, step) in steps.enumerated() { step.sortOrder = index }
    }

    private func deleteQuotes(at offsets: IndexSet) {
        offsets.map { quotes[$0] }.forEach(modelContext.delete)
    }
}
