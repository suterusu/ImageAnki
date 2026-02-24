import SwiftUI

@main
struct ImageAnkiApp: App {
    private let dependencies = AppDependencies.make(for: .live)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.wordChallengeStartScreenUseCase, dependencies.wordChallengeStartScreenUseCase)
                .environment(\.studySessionScreenUseCase, dependencies.studySessionScreenUseCase)
                .environment(\.performanceListScreenUseCase, dependencies.performanceListScreenUseCase)
                .environment(\.performanceDetailScreenUseCase, dependencies.performanceDetailScreenUseCase)
                .modelContainer(dependencies.modelContainer)
        }
    }
}
