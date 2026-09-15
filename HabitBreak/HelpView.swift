import SwiftData
import SwiftUI

struct HelpView: View {
    let sessionID: UUID
    @Query(sort: \Quote.createdAt) private var quotes: [Quote]
    @Query(sort: \HelpStep.sortOrder) private var steps: [HelpStep]
    @State private var completedStepIDs = Set<UUID>()
    @State private var displayedQuote: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    quoteSection
                    Divider()
                    Text("Take the next step").font(.title2.bold())
                    if steps.isEmpty {
                        Text("Add your personal response checklist in Settings.").foregroundStyle(.secondary)
                    } else {
                        ForEach(steps) { step in
                            Button {
                                toggle(step)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: completedStepIDs.contains(step.id) ? "checkmark.circle.fill" : "circle")
                                    Text(step.title).multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(24)
            }
            .navigationTitle("Help")
            .onAppear(perform: beginSession)
            .onChange(of: sessionID) { _, _ in beginSession() }
        }
    }

    @ViewBuilder private var quoteSection: some View {
        if let displayedQuote {
            Text("“\(displayedQuote)”")
                .font(.title2.weight(.medium))
                .foregroundStyle(.primary)
        } else {
            Text("You chose to pause. That already matters.")
                .font(.title2.weight(.medium))
            Text("Add personal quotes in Settings for a message that speaks to you.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private func beginSession() {
        completedStepIDs.removeAll()
        displayedQuote = quotes.randomElement()?.text
    }

    private func toggle(_ step: HelpStep) {
        if completedStepIDs.contains(step.id) {
            completedStepIDs.remove(step.id)
        } else {
            completedStepIDs.insert(step.id)
        }
    }
}
