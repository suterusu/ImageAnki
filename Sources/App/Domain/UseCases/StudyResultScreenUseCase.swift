// このファイルは自動生成されています

import Foundation

@MainActor
public protocol StudyResultScreenUseCaseProtocol: Sendable {
    func loadResult(sessionID: UUID) async -> AsyncStream<StudyResultScreenViewEffect>
    func backToProblemList() async -> AsyncStream<StudyResultScreenViewEffect>
    func restartReview(sessionID: UUID) async -> AsyncStream<StudyResultScreenViewEffect>
}

public struct UnimplementedStudyResultScreenUseCase: StudyResultScreenUseCaseProtocol {
    public nonisolated init() {}

    public func loadResult(sessionID: UUID) async -> AsyncStream<StudyResultScreenViewEffect> {
        fatalError("loadResult is not implemented")
    }

    public func backToProblemList() async -> AsyncStream<StudyResultScreenViewEffect> {
        fatalError("backToProblemList is not implemented")
    }

    public func restartReview(sessionID: UUID) async -> AsyncStream<StudyResultScreenViewEffect> {
        fatalError("restartReview is not implemented")
    }
}

@MainActor
public struct StudyResultScreenUseCase: StudyResultScreenUseCaseProtocol {
    private let wordRepository: any WordRepository
    private let studySessionRepository: any StudySessionRepository
    private let reviewPriorityService: any ReviewPriorityService

    public init(
        wordRepository: any WordRepository,
        studySessionRepository: any StudySessionRepository,
        reviewPriorityService: any ReviewPriorityService
    ) {
        self.wordRepository = wordRepository
        self.studySessionRepository = studySessionRepository
        self.reviewPriorityService = reviewPriorityService
    }

    public func loadResult(sessionID: UUID) async -> AsyncStream<StudyResultScreenViewEffect> {
        EffectStream.make { yield in
            yield(.showLoading)
            defer { yield(.hideLoading) }

            do {
                // 手順3: 対象学習回を読み込む
                guard let session = try await studySessionRepository.fetch(id: sessionID) else {
                    yield(.showError(.sessionNotFound))
                    return
                }

                let summary = session.summary()
                // 手順5,6,7: 正解数・不正解数・正誤詳細一覧を表示する
                yield(.showSummary(correctCount: summary.correctCount, incorrectCount: summary.incorrectCount))
                yield(.showAnswers(session.answers))
            } catch {
                yield(.showError(.loadFailed))
            }
        }
    }

    public func backToProblemList() async -> AsyncStream<StudyResultScreenViewEffect> {
        EffectStream.make { yield in
            // 手順2: 成績一覧画面へ遷移する
            yield(.navigateToProblemList)
        }
    }

    public func restartReview(sessionID: UUID) async -> AsyncStream<StudyResultScreenViewEffect> {
        EffectStream.make { yield in
            yield(.showLoading)
            defer { yield(.hideLoading) }

            do {
                guard let session = try await studySessionRepository.fetch(id: sessionID) else {
                    yield(.showError(.sessionNotFound))
                    return
                }

                let reviewCount = max(1, session.answers.filter { $0.judgment == .incorrect }.count)

                // 手順3: 復習学習を開始する
                let allSessions = try await studySessionRepository.fetchAll()
                let allWords = try await wordRepository.fetchAll()
                let reviewWords = reviewPriorityService.selectReviewWords(
                    sessions: allSessions,
                    from: allWords,
                    limit: reviewCount
                )

                guard !reviewWords.isEmpty else {
                    yield(.showError(.reviewStartFailed))
                    return
                }

                switch StudySession.make(mode: .review, grade: nil, requestedCount: reviewWords.count) {
                case .success(let reviewSession):
                    try await studySessionRepository.save(session: reviewSession)
                    // 手順4: 学習カード画面へ遷移する
                    yield(.navigateToStudyCard(reviewSession.id))
                case .failure:
                    yield(.showError(.reviewStartFailed))
                }
            } catch {
                yield(.showError(.reviewStartFailed))
            }
        }
    }
}

public enum StudyResultScreenError: Error, Equatable, Sendable {
    case sessionNotFound
    case loadFailed
    case reviewStartFailed
}
