// このファイルは自動生成されています

import Foundation

@MainActor
public protocol WordChallengeStartScreenUseCaseProtocol: Sendable {
    func loadSelection() async -> AsyncStream<WordChallengeStartScreenViewEffect>
    func startNormalStudy(
        selectedGrade: SchoolGrade?,
        selectedStudyCount: Int?,
        inputStudyCount: String
    ) async -> AsyncStream<WordChallengeStartScreenViewEffect>
    func startReviewStudy(
        selectedStudyCount: Int?,
        inputStudyCount: String
    ) async -> AsyncStream<WordChallengeStartScreenViewEffect>
}

public struct UnimplementedWordChallengeStartScreenUseCase: WordChallengeStartScreenUseCaseProtocol {
    public nonisolated init() {}

    public func loadSelection() async -> AsyncStream<WordChallengeStartScreenViewEffect> {
        fatalError("loadSelection is not implemented")
    }

    public func startNormalStudy(
        selectedGrade: SchoolGrade?,
        selectedStudyCount: Int?,
        inputStudyCount: String
    ) async -> AsyncStream<WordChallengeStartScreenViewEffect> {
        fatalError("startNormalStudy is not implemented")
    }

    public func startReviewStudy(
        selectedStudyCount: Int?,
        inputStudyCount: String
    ) async -> AsyncStream<WordChallengeStartScreenViewEffect> {
        fatalError("startReviewStudy is not implemented")
    }
}

@MainActor
public struct WordChallengeStartScreenUseCase: WordChallengeStartScreenUseCaseProtocol {
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

    public func loadSelection() async -> AsyncStream<WordChallengeStartScreenViewEffect> {
        EffectStream.make { yield in
            // 手順2,3: 学年選択肢と学習数選択肢を表示する
            yield(.showSelectedGrade(.middle1))
            yield(.showSelectedStudyCount(10))
            yield(.clearInputError)
        }
    }

    public func startNormalStudy(
        selectedGrade: SchoolGrade?,
        selectedStudyCount: Int?,
        inputStudyCount: String
    ) async -> AsyncStream<WordChallengeStartScreenViewEffect> {
        EffectStream.make { yield in
            // 手順2-A: 開始条件を検証する
            guard let selectedGrade else {
                yield(.showInputError(.gradeNotSelected))
                return
            }

            let resolvedCount: Int?
            if let selectedStudyCount {
                resolvedCount = selectedStudyCount
            } else if !inputStudyCount.isEmpty {
                resolvedCount = Int(inputStudyCount)
            } else {
                resolvedCount = nil
            }

            guard let resolvedCount, resolvedCount > 0 else {
                yield(.showInputError(.invalidStudyCount))
                return
            }

            yield(.clearInputError)
            yield(.showLoading)
            defer { yield(.hideLoading) }

            do {
                // 手順4: 選択学年の問題を学習数ぶん読み込む
                let words = try await wordRepository.fetchByGrade(grade: selectedGrade, limit: resolvedCount)
                guard words.count == resolvedCount else {
                    yield(.showError(.wordsNotFound))
                    return
                }

                switch StudySession.make(mode: .normal, grade: selectedGrade, requestedCount: resolvedCount) {
                case .success(let session):
                    try await studySessionRepository.save(session: session)
                    // 手順6: 学習カード画面へ遷移する
                    yield(.navigateToStudyCard(session.id))
                case .failure:
                    yield(.showError(.startFailed))
                }
            } catch {
                yield(.showError(.startFailed))
            }
        }
    }

    public func startReviewStudy(
        selectedStudyCount: Int?,
        inputStudyCount: String
    ) async -> AsyncStream<WordChallengeStartScreenViewEffect> {
        EffectStream.make { yield in
            // 手順2: 開始条件を検証する
            let resolvedCount: Int?
            if let selectedStudyCount {
                resolvedCount = selectedStudyCount
            } else if !inputStudyCount.isEmpty {
                resolvedCount = Int(inputStudyCount)
            } else {
                resolvedCount = nil
            }

            guard let resolvedCount, resolvedCount > 0 else {
                yield(.showInputError(.invalidStudyCount))
                return
            }

            yield(.clearInputError)
            yield(.showLoading)
            defer { yield(.hideLoading) }

            do {
                // 手順4: 復習優先度順の問題を学習数ぶん選定する
                let sessions = try await studySessionRepository.fetchAll()
                let words = try await wordRepository.fetchAll()
                let reviewWords = reviewPriorityService.selectReviewWords(
                    sessions: sessions,
                    from: words,
                    limit: resolvedCount
                )

                guard reviewWords.count == resolvedCount else {
                    yield(.showError(.reviewTargetsNotFound))
                    return
                }

                switch StudySession.make(mode: .review, grade: nil, requestedCount: resolvedCount) {
                case .success(let session):
                    try await studySessionRepository.save(session: session)
                    // 手順6: 学習カード画面へ遷移する
                    yield(.navigateToStudyCard(session.id))
                case .failure:
                    yield(.showError(.startFailed))
                }
            } catch {
                yield(.showError(.startFailed))
            }
        }
    }
}

public enum WordChallengeStartScreenError: Error, Equatable, Sendable {
    case gradeNotSelected
    case invalidStudyCount
    case wordsNotFound
    case reviewTargetsNotFound
    case startFailed
}
