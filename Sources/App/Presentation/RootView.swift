import SwiftUI

public struct RootView: View {
    @State private var appState = AppState()

    public init() {}

    public var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            TabView(selection: $appState.selectedTab) {
                WordChallengeStartScreenView()
                    .tabItem { Label("単語挑戦", systemImage: "book") }
                    .tag(AppTab.wordChallengeStart)

                PerformanceListScreenView()
                    .tabItem { Label("成績一覧", systemImage: "chart.bar") }
                    .tag(AppTab.performanceList)
            }
            .navigationDestination(for: Screen.self) { destination in
                switch destination {
                case .studySession(let sessionID):
                    StudySessionScreenView(sessionID: sessionID)
                case .performanceDetail(let sessionID):
                    PerformanceDetailScreenView(sessionID: sessionID)
                }
            }
        }
        .environment(appState)
    }
}
