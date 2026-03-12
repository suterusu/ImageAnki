import SwiftData
import SwiftUI

@main
struct WordBookApp: App {
    private let di = AppDependencies.make(for: .live)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.wordListUseCase, di.wordListUseCase)
                .environment(\.createWordUseCase, di.createWordUseCase)
                .environment(\.studyUseCase, di.studyUseCase)
                .modelContainer(di.modelContainer)
        }
    }
}

@MainActor
public struct AppDependencies {
    public enum Environment {
        case live
        case preview
        case test
    }
    
    let environment: Environment

    public let modelContainer: ModelContainer

    public let wordListUseCase: any WordListUseCaseProtocol
    public let createWordUseCase: any CreateWordUseCaseProtocol
    public let studyUseCase: any StudyUseCaseProtocol
    
    fileprivate let vocabularyCardRepository: any VocabularyCardRepository

    public static func make(for environment: Environment) -> AppDependencies {
        do {
            let modelContainer = try {
                switch environment {
                case .live:
                    try ModelContainer(for: VocabularyCardPersistentModel.self)
                case .preview, .test:
                    try ModelContainer(
                        for: VocabularyCardPersistentModel.self,
                        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                    )
                }
            }()

            let repository = SwiftDataRepository<VocabularyCardBiMapper>(
                context: modelContainer.mainContext,
                mapper: VocabularyCardBiMapper()
            )

            return AppDependencies(
                environment: environment,
                modelContainer: modelContainer,
                wordListUseCase: WordListUseCase(vocabularyCardRepository: repository),
                createWordUseCase: CreateWordUseCase(vocabularyCardRepository: repository),
                studyUseCase: StudyUseCase(vocabularyCardRepository: repository),
                vocabularyCardRepository: repository
            )
        } catch {
            fatalError("Failed to build AppDependencies: \(error)")
        }
    }
}

extension AppDependencies {
    var vocabularyCardRepositoryForTest: any VocabularyCardRepository {
        assert(environment == .test)
        return vocabularyCardRepository
    }
}

extension EnvironmentValues {
    @Entry var wordListUseCase: any WordListUseCaseProtocol = UnimplementedWordListUseCase()
    @Entry var createWordUseCase: any CreateWordUseCaseProtocol = UnimplementedCreateWordUseCase()
    @Entry var studyUseCase: any StudyUseCaseProtocol = UnimplementedStudyUseCase()
}
