// このファイルは自動生成されています

import Foundation

@MainActor
public protocol StudyCardScreenUseCaseProtocol: Sendable {
    func loadCards(sessionID: UUID) async -> AsyncStream<StudyCardScreenViewEffect>
    func judgeCorrect(sessionID: UUID, wordID: UUID) async -> AsyncStream<StudyCardScreenViewEffect>
    func judgeIncorrect(sessionID: UUID, wordID: UUID) async -> AsyncStream<StudyCardScreenViewEffect>
    func toggleCardFace(isAnswerSide: Bool) async -> AsyncStream<StudyCardScreenViewEffect>
}

public struct UnimplementedStudyCardScreenUseCase: StudyCardScreenUseCaseProtocol {
    public nonisolated init() {}

    public func loadCards(sessionID: UUID) async -> AsyncStream<StudyCardScreenViewEffect> {
        fatalError("loadCards is not implemented")
    }

    public func judgeCorrect(sessionID: UUID, wordID: UUID) async -> AsyncStream<StudyCardScreenViewEffect> {
        fatalError("judgeCorrect is not implemented")
    }

    public func judgeIncorrect(sessionID: UUID, wordID: UUID) async -> AsyncStream<StudyCardScreenViewEffect> {
        fatalError("judgeIncorrect is not implemented")
    }

    public func toggleCardFace(isAnswerSide: Bool) async -> AsyncStream<StudyCardScreenViewEffect> {
        fatalError("toggleCardFace is not implemented")
    }
}

@MainActor
public struct StudyCardScreenUseCase: StudyCardScreenUseCaseProtocol {
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

    public func loadCards(sessionID: UUID) async -> AsyncStream<StudyCardScreenViewEffect> {
        EffectStream.make { yield in
            yield(.showLoading)
            defer { yield(.hideLoading) }

            do {
                // 手順3: 出題カードを読み込む
                guard let session = try await studySessionRepository.fetch(id: sessionID) else {
                    yield(.showError(.sessionNotFound))
                    return
                }

                let cards: [Word]
                if session.mode == .normal, let grade = session.grade {
                    cards = try await wordRepository.fetchByGrade(grade: grade, limit: session.requestedCount)
                } else {
                    let sessions = try await studySessionRepository.fetchAll()
                    let allWords = try await wordRepository.fetchAll()
                    cards = reviewPriorityService.selectReviewWords(
                        sessions: sessions,
                        from: allWords,
                        limit: session.requestedCount
                    )
                }

                guard let firstCard = cards.first else {
                    yield(.showError(.cardsNotFound))
                    return
                }

                // 手順5,6: 出題カードと進捗情報を表示する
                yield(.showCard(firstCard))
                yield(.updateProgress(current: 1, total: cards.count))
                yield(.setCardFace(isAnswerSide: false))
            } catch {
                yield(.showError(.loadFailed))
            }
        }
    }

    public func judgeCorrect(sessionID: UUID, wordID: UUID) async -> AsyncStream<StudyCardScreenViewEffect> {
        EffectStream.make { yield in
            do {
                // 手順2: 正解判定を記録する
                guard var session = try await studySessionRepository.fetch(id: sessionID) else {
                    yield(.showError(.sessionNotFound))
                    return
                }

                switch StudyAnswer.make(wordID: wordID, judgment: .correct) {
                case .success(let answer):
                    session.recordAnswer(answer: answer)
                case .failure:
                    yield(.showError(.saveFailed))
                    return
                }

                if session.answers.count >= session.requestedCount {
                    // 手順2-A,3-A: 学習結果を集計して成績詳細へ遷移する
                    session.finalize()
                    try await studySessionRepository.save(session: session)
                    yield(.navigateToStudyResult(session.id))
                    return
                }

                try await studySessionRepository.save(session: session)

                let cards: [Word]
                if session.mode == .normal, let grade = session.grade {
                    cards = try await wordRepository.fetchByGrade(grade: grade, limit: session.requestedCount)
                } else {
                    let sessions = try await studySessionRepository.fetchAll()
                    let allWords = try await wordRepository.fetchAll()
                    cards = reviewPriorityService.selectReviewWords(
                        sessions: sessions,
                        from: allWords,
                        limit: session.requestedCount
                    )
                }

                let nextIndex = session.answers.count
                if cards.indices.contains(nextIndex) {
                    // 手順3: 次の出題カードを表示する
                    yield(.showCard(cards[nextIndex]))
                    yield(.updateProgress(current: nextIndex + 1, total: cards.count))
                    yield(.setCardFace(isAnswerSide: false))
                }
            } catch {
                // 手順3-B: エラーアラートを表示する
                yield(.showError(.saveFailed))
            }
        }
    }

    public func judgeIncorrect(sessionID: UUID, wordID: UUID) async -> AsyncStream<StudyCardScreenViewEffect> {
        EffectStream.make { yield in
            do {
                // 手順2: 不正解判定を記録する
                guard var session = try await studySessionRepository.fetch(id: sessionID) else {
                    yield(.showError(.sessionNotFound))
                    return
                }

                switch StudyAnswer.make(wordID: wordID, judgment: .incorrect) {
                case .success(let answer):
                    session.recordAnswer(answer: answer)
                case .failure:
                    yield(.showError(.saveFailed))
                    return
                }

                if session.answers.count >= session.requestedCount {
                    // 手順2-A,3-A: 学習結果を集計して成績詳細へ遷移する
                    session.finalize()
                    try await studySessionRepository.save(session: session)
                    yield(.navigateToStudyResult(session.id))
                    return
                }

                try await studySessionRepository.save(session: session)

                let cards: [Word]
                if session.mode == .normal, let grade = session.grade {
                    cards = try await wordRepository.fetchByGrade(grade: grade, limit: session.requestedCount)
                } else {
                    let sessions = try await studySessionRepository.fetchAll()
                    let allWords = try await wordRepository.fetchAll()
                    cards = reviewPriorityService.selectReviewWords(
                        sessions: sessions,
                        from: allWords,
                        limit: session.requestedCount
                    )
                }

                let nextIndex = session.answers.count
                if cards.indices.contains(nextIndex) {
                    // 手順3: 次の出題カードを表示する
                    yield(.showCard(cards[nextIndex]))
                    yield(.updateProgress(current: nextIndex + 1, total: cards.count))
                    yield(.setCardFace(isAnswerSide: false))
                }
            } catch {
                // 手順3-B: エラーアラートを表示する
                yield(.showError(.saveFailed))
            }
        }
    }

    public func toggleCardFace(isAnswerSide: Bool) async -> AsyncStream<StudyCardScreenViewEffect> {
        EffectStream.make { yield in
            // 手順2: カード表示面を切り替える
            yield(.setCardFace(isAnswerSide: !isAnswerSide))
        }
    }
}

public enum StudyCardScreenError: Error, Equatable, Sendable {
    case sessionNotFound
    case cardsNotFound
    case saveFailed
    case loadFailed
}
