import Foundation
import SwiftData
import SwiftUI

@MainActor
public struct AppDependencies {
    public enum Environment {
        case live
        case preview
        case test
    }

    let environment: Environment

    public let modelContainer: ModelContainer

    public let wordChallengeStartScreenUseCase: any WordChallengeStartScreenUseCaseProtocol
    public let studySessionScreenUseCase: any StudySessionScreenUseCaseProtocol
    public let performanceListScreenUseCase: any PerformanceListScreenUseCaseProtocol
    public let performanceDetailScreenUseCase: any PerformanceDetailScreenUseCaseProtocol

    fileprivate let wordCardRepository: any WordCardRepository
    fileprivate let studySessionRepository: any StudySessionRepository

    public static func make(for environment: Environment) -> AppDependencies {
        do {
            let configuration: ModelConfiguration
            switch environment {
            case .live:
                configuration = ModelConfiguration(isStoredInMemoryOnly: false)
            case .preview, .test:
                configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            }

            let container = try ModelContainer(
                for: WordCardPersistentModel.self,
                StudySessionPersistentModel.self,
                configurations: configuration
            )

            let wordCardRepository = SwiftDataRepository_WordCard(
                context: container.mainContext,
                mapper: WordCardBiMapper()
            )
            let studySessionRepository = SwiftDataRepository_StudySession(
                context: container.mainContext,
                mapper: StudySessionBiMapper()
            )

            let dependencies = AppDependencies(
                environment: environment,
                modelContainer: container,
                wordChallengeStartScreenUseCase: WordChallengeStartScreenUseCase(
                    wordCardRepository: wordCardRepository,
                    studySessionRepository: studySessionRepository,
                    reviewSelectionService: DefaultReviewSelectionService()
                ),
                studySessionScreenUseCase: StudySessionScreenUseCase(
                    studySessionRepository: studySessionRepository,
                    wordCardRepository: wordCardRepository
                ),
                performanceListScreenUseCase: PerformanceListScreenUseCase(
                    studySessionRepository: studySessionRepository
                ),
                performanceDetailScreenUseCase: PerformanceDetailScreenUseCase(
                    studySessionRepository: studySessionRepository,
                    wordCardRepository: wordCardRepository
                ),
                wordCardRepository: wordCardRepository,
                studySessionRepository: studySessionRepository
            )

            if environment != .test {
                Task { @MainActor in
                    try? await dependencies.seedWordCardsIfNeeded()
                }
            }
            return dependencies
        } catch {
            fatalError("Failed to build AppDependencies: \(error)")
        }
    }

    private func seedWordCardsIfNeeded() async throws {
        let existing = try await wordCardRepository.fetchAll()
        guard existing.isEmpty else { return }

        let seeds: [(SchoolGrade, String, String, String)] = [
            (.junior1, "apple", "りんご", "apple.png"),
            (.junior2, "science", "科学", "science.png"),
            (.junior3, "environment", "環境", "environment.png")
        ]

        for seed in seeds {
            switch WordCard.make(grade: seed.0, promptText: seed.1, meaningText: seed.2, imagePNGName: seed.3) {
            case .success(let card):
                try await wordCardRepository.insert(card)
            case .failure:
                continue
            }
        }
    }
}

extension AppDependencies {
    public var wordCardRepositoryForTest: any WordCardRepository {
        assert(environment == .test)
        return wordCardRepository
    }

    public var studySessionRepositoryForTest: any StudySessionRepository {
        assert(environment == .test)
        return studySessionRepository
    }
}

private struct WordChallengeStartScreenUseCaseKey: EnvironmentKey {
    static let defaultValue: any WordChallengeStartScreenUseCaseProtocol = UnimplementedWordChallengeStartScreenUseCase()
}

private struct StudySessionScreenUseCaseKey: EnvironmentKey {
    static let defaultValue: any StudySessionScreenUseCaseProtocol = UnimplementedStudySessionScreenUseCase()
}

private struct PerformanceListScreenUseCaseKey: EnvironmentKey {
    static let defaultValue: any PerformanceListScreenUseCaseProtocol = UnimplementedPerformanceListScreenUseCase()
}

private struct PerformanceDetailScreenUseCaseKey: EnvironmentKey {
    static let defaultValue: any PerformanceDetailScreenUseCaseProtocol = UnimplementedPerformanceDetailScreenUseCase()
}

extension EnvironmentValues {
    public var wordChallengeStartScreenUseCase: any WordChallengeStartScreenUseCaseProtocol {
        get { self[WordChallengeStartScreenUseCaseKey.self] }
        set { self[WordChallengeStartScreenUseCaseKey.self] = newValue }
    }

    public var studySessionScreenUseCase: any StudySessionScreenUseCaseProtocol {
        get { self[StudySessionScreenUseCaseKey.self] }
        set { self[StudySessionScreenUseCaseKey.self] = newValue }
    }

    public var performanceListScreenUseCase: any PerformanceListScreenUseCaseProtocol {
        get { self[PerformanceListScreenUseCaseKey.self] }
        set { self[PerformanceListScreenUseCaseKey.self] = newValue }
    }

    public var performanceDetailScreenUseCase: any PerformanceDetailScreenUseCaseProtocol {
        get { self[PerformanceDetailScreenUseCaseKey.self] }
        set { self[PerformanceDetailScreenUseCaseKey.self] = newValue }
    }
}
