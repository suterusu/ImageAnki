// このファイルは自動生成されています

import SwiftUI

public struct RootView: View {
    @State private var appState = AppState()

    public init() {}

    public var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            TabView(selection: $appState.selectedTab) {
                WordChallengeStartScreenView()
                    .tabItem { Label("単語挑戦", systemImage: "bolt.fill") }
                    .tag(AppTab.wordChallengeStart)

                ProblemListScreenView()
                    .tabItem { Label("成績一覧", systemImage: "list.bullet.rectangle") }
                    .tag(AppTab.problemList)
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .studyCard(let sessionID):
                    StudyCardScreenView(sessionID: sessionID)
                case .studyResult(let sessionID):
                    StudyResultScreenView(sessionID: sessionID)
                }
            }
        }
        .environment(appState)
    }
}
