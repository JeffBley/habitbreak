import SwiftUI

enum AppTab: Hashable {
    case summary, habits, tracker, help, settings
}

struct RootView: View {
    @State private var selection: AppTab = .summary
    @State private var helpSessionID = UUID()

    var body: some View {
        TabView(selection: $selection) {
            SummaryView().tag(AppTab.summary)
            HabitsView().tag(AppTab.habits)
            TrackerView().tag(AppTab.tracker)
            HelpView(sessionID: helpSessionID).tag(AppTab.help)
            SettingsView().tag(AppTab.settings)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .tint(.primary)
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            tabButton("Summary", icon: "chart.bar", tab: .summary)
            tabButton("Habits", icon: "list.bullet", tab: .habits)
            helpButton
            tabButton("Tracker", icon: "calendar", tab: .tracker)
            tabButton("Settings", icon: "gearshape", tab: .settings)
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }

    private func tabButton(_ title: String, icon: String, tab: AppTab) -> some View {
        Button {
            selection = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 19))
                Text(title).font(.caption2)
            }
            .foregroundStyle(selection == tab ? .primary : .secondary)
            .frame(maxWidth: .infinity, minHeight: 48)
        }
        .accessibilityLabel(title)
    }

    private var helpButton: some View {
        Button {
            helpSessionID = UUID()
            selection = .help
        } label: {
            VStack(spacing: 3) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 22))
                    .frame(width: 52, height: 52)
                    .background(Color.primary)
                    .foregroundStyle(Color(uiColor: .systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 5, y: 2)
                Text("Help").font(.caption2)
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .offset(y: -13)
        }
        .accessibilityLabel("Help")
    }
}
