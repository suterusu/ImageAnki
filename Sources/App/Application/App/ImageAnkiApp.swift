// このファイルは自動生成されています

import SwiftData
import SwiftUI

@main
struct ImageAnkiApp: App {
    private let dependencies = AppDependencies.make(for: .live)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.wordChallengeStartScreenUseCase, dependencies.wordChallengeStartScreenUseCase)
                .environment(\.studyCardScreenUseCase, dependencies.studyCardScreenUseCase)
                .environment(\.studyResultScreenUseCase, dependencies.studyResultScreenUseCase)
                .environment(\.problemListScreenUseCase, dependencies.problemListScreenUseCase)
                .modelContainer(dependencies.modelContainer)
        }
    }
}
