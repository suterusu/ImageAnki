// このファイルは自動生成されています

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
    public let studyCardScreenUseCase: any StudyCardScreenUseCaseProtocol
    public let studyResultScreenUseCase: any StudyResultScreenUseCaseProtocol
    public let problemListScreenUseCase: any ProblemListScreenUseCaseProtocol

    fileprivate let wordRepository: any WordRepository
    fileprivate let studySessionRepository: any StudySessionRepository

    public static func make(for environment: Environment) -> AppDependencies {
        do {
            let modelContainer = try {
                switch environment {
                case .live:
                    try ModelContainer(
                        for: WordPersistentModel.self,
                        StudySessionPersistentModel.self,
                        StudyAnswerPersistentModel.self
                    )
                case .preview, .test:
                    try ModelContainer(
                        for: WordPersistentModel.self,
                        StudySessionPersistentModel.self,
                        StudyAnswerPersistentModel.self,
                        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                    )
                }
            }()

            if environment != .test {
                try seedInitialWordsIfNeeded(context: modelContainer.mainContext)
            }

            let wordRepository = SwiftDataRepository_Word(context: modelContainer.mainContext)
            let sessionRepository = SwiftDataRepository_StudySession(context: modelContainer.mainContext)
            let reviewPriorityService = DefaultReviewPriorityService()

            let wordChallengeStartScreenUseCase = WordChallengeStartScreenUseCase(
                wordRepository: wordRepository,
                studySessionRepository: sessionRepository,
                reviewPriorityService: reviewPriorityService
            )

            let studyCardScreenUseCase = StudyCardScreenUseCase(
                wordRepository: wordRepository,
                studySessionRepository: sessionRepository,
                reviewPriorityService: reviewPriorityService
            )

            let studyResultScreenUseCase = StudyResultScreenUseCase(
                wordRepository: wordRepository,
                studySessionRepository: sessionRepository,
                reviewPriorityService: reviewPriorityService
            )

            let problemListScreenUseCase = ProblemListScreenUseCase(
                studySessionRepository: sessionRepository
            )

            return AppDependencies(
                environment: environment,
                modelContainer: modelContainer,
                wordChallengeStartScreenUseCase: wordChallengeStartScreenUseCase,
                studyCardScreenUseCase: studyCardScreenUseCase,
                studyResultScreenUseCase: studyResultScreenUseCase,
                problemListScreenUseCase: problemListScreenUseCase,
                wordRepository: wordRepository,
                studySessionRepository: sessionRepository
            )
        } catch {
            fatalError("Failed to build AppDependencies: \(error)")
        }
    }

    private static func seedInitialWordsIfNeeded(context: ModelContext) throws {
        let existing = try context.fetch(FetchDescriptor<WordPersistentModel>())
        let minimumCountPerGrade = 30

        for grade in SchoolGrade.allCases {
            let currentCount = existing.filter { $0.gradeRawValue == grade.rawValue }.count
            guard currentCount < minimumCountPerGrade else { continue }

            let prefix: String
            switch grade {
            case .middle1: prefix = "m1"
            case .middle2: prefix = "m2"
            case .middle3: prefix = "m3"
            }

            for index in (currentCount + 1)...minimumCountPerGrade {
                context.insert(
                    WordPersistentModel(
                        id: UUID(),
                        gradeRawValue: grade.rawValue,
                        problemImageName: "\(prefix)_problem_\(String(format: "%02d", index))",
                        answerImageName: "\(prefix)_answer_\(String(format: "%02d", index))"
                    )
                )
            }
        }

        try context.save()
    }
}

extension AppDependencies {
    public var wordRepositoryForTest: any WordRepository {
        assert(environment == .test)
        return wordRepository
    }

    public var studySessionRepositoryForTest: any StudySessionRepository {
        assert(environment == .test)
        return studySessionRepository
    }
}

extension EnvironmentValues {
    @Entry public var wordChallengeStartScreenUseCase: any WordChallengeStartScreenUseCaseProtocol = UnimplementedWordChallengeStartScreenUseCase()
    @Entry public var studyCardScreenUseCase: any StudyCardScreenUseCaseProtocol = UnimplementedStudyCardScreenUseCase()
    @Entry public var studyResultScreenUseCase: any StudyResultScreenUseCaseProtocol = UnimplementedStudyResultScreenUseCase()
    @Entry public var problemListScreenUseCase: any ProblemListScreenUseCaseProtocol = UnimplementedProblemListScreenUseCase()
}
