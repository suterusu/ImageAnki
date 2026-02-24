// 自動生成
import Foundation

@MainActor
public protocol WordChallengeStartScreenUseCaseProtocol {
    func startLearning(grade: SchoolGrade, itemCountText: String) async -> AsyncStream<WordChallengeStartViewEffect>
    func startReview(itemCountText: String) async -> AsyncStream<WordChallengeStartViewEffect>
    func handleAlertResult(
        _ alertEffect: WordChallengeStartAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<WordChallengeStartViewEffect>
}

public struct UnimplementedWordChallengeStartScreenUseCase: WordChallengeStartScreenUseCaseProtocol {
    public nonisolated init() {}

    public func startLearning(grade: SchoolGrade, itemCountText: String) async -> AsyncStream<WordChallengeStartViewEffect> {
        fatalError("startLearning is not implemented")
    }

    public func startReview(itemCountText: String) async -> AsyncStream<WordChallengeStartViewEffect> {
        fatalError("startReview is not implemented")
    }

    public func handleAlertResult(
        _ alertEffect: WordChallengeStartAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<WordChallengeStartViewEffect> {
        fatalError("handleAlertResult is not implemented")
    }
}

@MainActor
public struct WordChallengeStartScreenUseCase: WordChallengeStartScreenUseCaseProtocol {
    private let wordCardRepository: any WordCardRepository
    private let studySessionRepository: any StudySessionRepository
    private let reviewSelectionService: any ReviewSelectionService

    public init(
        wordCardRepository: any WordCardRepository,
        studySessionRepository: any StudySessionRepository,
        reviewSelectionService: any ReviewSelectionService
    ) {
        self.wordCardRepository = wordCardRepository
        self.studySessionRepository = studySessionRepository
        self.reviewSelectionService = reviewSelectionService
    }

    public func startLearning(grade: SchoolGrade, itemCountText: String) async -> AsyncStream<WordChallengeStartViewEffect> {
        EffectStream.make { yield in
            // ユースケース2 基本フロー1: 学習開始要求を受け取り、入力値を検証する
            // ユースケース2 入力不正時: 学習開始前にエラー表示して終了する
            let targetCount: StudyItemCount
            do {
                guard let count = Int(itemCountText) else {
                    yield(.screen(.showInputError))
                    yield(.alert(.showError(.invalidStudyItemCount)))
                    return
                }
                targetCount = try StudyItemCount(count)
                yield(.screen(.clearInputError))
            } catch {
                yield(.screen(.showInputError))
                yield(.alert(.showError(.invalidStudyItemCount)))
                return
            }

            // ユースケース2 基本フロー2: ローディング状態を表示する
            yield(.screen(.showLoading))
            // ユースケース2 基本フロー4: ローディング状態を非表示にする
            defer { yield(.screen(.hideLoading)) }

            do {
                // ユースケース2 基本フロー3: 学年と学習数に合致する出題カードを読み込む
                let cards = try await wordCardRepository.fetchByGrade(grade: grade, count: targetCount)
                guard !cards.isEmpty else {
                    // ユースケース2 分岐フローA 3-A,5-A,6-A: 0件時は空状態メッセージを表示して終了
                    yield(.screen(.showEmptyState("対象の単語カードがありません。")))
                    return
                }

                // ユースケース2 基本フロー5: 読み込み済みカードで学習セッションを開始する
                let sessionResult = StudySession.make(
                    startedAt: Date(),
                    mode: .learning,
                    gradeFilter: grade,
                    targetCount: cards.count,
                    cardIDs: cards.map(\.id)
                )
                guard case .success(let session) = sessionResult else {
                    yield(.alert(.showError(.startSessionFailed)))
                    return
                }
                try await studySessionRepository.insert(session)
                yield(.screen(.hideEmptyState))
                // ユースケース2 基本フロー6: 学習セッション画面へ遷移する
                yield(.screen(.navigateToStudySession(sessionID: session.id)))
            } catch {
                // ユースケース2 例外フローB 3-B,5-B,6-B: 読み込み失敗時はエラーアラートを表示して終了
                yield(.alert(.showError(.fetchCardsFailed)))
            }
        }
    }

    public func startReview(itemCountText: String) async -> AsyncStream<WordChallengeStartViewEffect> {
        EffectStream.make { yield in
            // ユースケース3 基本フロー1: 復習開始要求を受け取り、入力値を検証する
            // ユースケース3 入力不正時: 復習開始前にエラー表示して終了する
            let targetCount: StudyItemCount
            do {
                guard let count = Int(itemCountText) else {
                    yield(.screen(.showInputError))
                    yield(.alert(.showError(.invalidStudyItemCount)))
                    return
                }
                targetCount = try StudyItemCount(count)
                yield(.screen(.clearInputError))
            } catch {
                yield(.screen(.showInputError))
                yield(.alert(.showError(.invalidStudyItemCount)))
                return
            }

            // ユースケース3 基本フロー2: ローディング状態を表示する
            yield(.screen(.showLoading))
            // ユースケース3 基本フロー5: ローディング状態を非表示にする
            defer { yield(.screen(.hideLoading)) }

            do {
                // ユースケース3 基本フロー3: 全学年の誤答履歴を読み込む
                // ユースケース3 基本フロー4: 復習優先度順で出題カードを選定する
                let sessions = try await studySessionRepository.fetchAll()
                let ids = try reviewSelectionService.selectReviewCardIDs(
                    sessions: sessions,
                    targetCount: targetCount,
                    now: Date()
                )
                guard !ids.isEmpty else {
                    // ユースケース3 分岐フローA 4-A,6-A,7-A: 復習対象が0件のとき空状態を表示して終了
                    yield(.screen(.showEmptyState("復習対象のカードがありません。")))
                    return
                }

                let cards = try await wordCardRepository.fetchByIDs(ids: ids)
                guard !cards.isEmpty else {
                    // ユースケース3 分岐フローA 4-A,6-A,7-A: 復習対象が0件のとき空状態を表示して終了
                    yield(.screen(.showEmptyState("復習対象のカードがありません。")))
                    return
                }

                // ユースケース3 基本フロー6: 選定済みカードで学習セッションを開始する
                let sessionResult = StudySession.make(
                    startedAt: Date(),
                    mode: .review,
                    gradeFilter: nil,
                    targetCount: cards.count,
                    cardIDs: cards.map(\.id)
                )
                guard case .success(let session) = sessionResult else {
                    yield(.alert(.showError(.startSessionFailed)))
                    return
                }
                try await studySessionRepository.insert(session)
                yield(.screen(.hideEmptyState))
                // ユースケース3 基本フロー7: 学習セッション画面へ遷移する
                yield(.screen(.navigateToStudySession(sessionID: session.id)))
            } catch {
                // ユースケース3 例外フローB 4-B,6-B,7-B: 選定失敗時はエラーアラートを表示して終了
                yield(.alert(.showError(.reviewSelectionFailed)))
            }
        }
    }

    public func handleAlertResult(
        _ alertEffect: WordChallengeStartAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<WordChallengeStartViewEffect> {
        EffectStream.make { _ in
            switch (alertEffect, buttonType) {
            case (_, .cancel), (.showError, .confirm):
                break
            }
        }
    }
}

public enum WordChallengeStartError: Error, Equatable, Sendable {
    case invalidStudyItemCount
    case fetchCardsFailed
    case reviewSelectionFailed
    case startSessionFailed
}
