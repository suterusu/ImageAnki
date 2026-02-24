// 自動生成
import Foundation

@MainActor
public protocol StudySessionScreenUseCaseProtocol {
    func loadSession(sessionID: UUID) async -> AsyncStream<StudySessionViewEffect>
    func submitJudgment(sessionID: UUID, judgment: AnswerJudgment) async -> AsyncStream<StudySessionViewEffect>
    func toggleCardFace() async -> AsyncStream<StudySessionViewEffect>
    func handleAlertResult(
        _ alertEffect: StudySessionAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<StudySessionViewEffect>
}

public struct UnimplementedStudySessionScreenUseCase: StudySessionScreenUseCaseProtocol {
    public nonisolated init() {}

    public func loadSession(sessionID: UUID) async -> AsyncStream<StudySessionViewEffect> {
        fatalError("loadSession is not implemented")
    }

    public func submitJudgment(sessionID: UUID, judgment: AnswerJudgment) async -> AsyncStream<StudySessionViewEffect> {
        fatalError("submitJudgment is not implemented")
    }

    public func toggleCardFace() async -> AsyncStream<StudySessionViewEffect> {
        fatalError("toggleCardFace is not implemented")
    }

    public func handleAlertResult(
        _ alertEffect: StudySessionAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<StudySessionViewEffect> {
        fatalError("handleAlertResult is not implemented")
    }
}

@MainActor
public struct StudySessionScreenUseCase: StudySessionScreenUseCaseProtocol {
    private let studySessionRepository: any StudySessionRepository
    private let wordCardRepository: any WordCardRepository

    public init(
        studySessionRepository: any StudySessionRepository,
        wordCardRepository: any WordCardRepository
    ) {
        self.studySessionRepository = studySessionRepository
        self.wordCardRepository = wordCardRepository
    }

    public func loadSession(sessionID: UUID) async -> AsyncStream<StudySessionViewEffect> {
        EffectStream.make { yield in
            // ユースケース1 基本フロー2: ローディング状態を表示する
            yield(.screen(.showLoading))
            // ユースケース1 基本フロー4: ローディング状態を非表示にする
            defer { yield(.screen(.hideLoading)) }

            do {
                // ユースケース1 基本フロー3: 開始済み学習セッションの現在カード情報を読み込む
                guard let session = try await studySessionRepository.fetch(id: sessionID),
                      let currentCardID = session.currentCardID else {
                    // ユースケース1 例外フローA 3-A,5-A,6-A: 読み込み失敗時はエラー表示して終了
                    yield(.alert(.showError(.sessionNotFound)))
                    return
                }
                let cards = try await wordCardRepository.fetchByIDs(ids: [currentCardID])
                guard let currentCard = cards.first else {
                    // ユースケース1 例外フローA 3-A,5-A,6-A: 読み込み失敗時はエラー表示して終了
                    yield(.alert(.showError(.cardNotFound)))
                    return
                }
                // ユースケース1 基本フロー5: 現在カード画像を表示する
                // ユースケース1 基本フロー6: 進捗情報を表示する
                yield(.screen(.showPromptFace))
                yield(.screen(.updateCard(currentCard)))
                yield(.screen(.updateProgress(answeredCount: session.answeredCount, totalCount: session.targetCount.value)))
            } catch {
                // ユースケース1 例外フローA 3-A,5-A,6-A: 読み込み失敗時はエラー表示して終了
                yield(.alert(.showError(.loadFailed)))
            }
        }
    }

    public func submitJudgment(sessionID: UUID, judgment: AnswerJudgment) async -> AsyncStream<StudySessionViewEffect> {
        EffectStream.make { yield in
            do {
                // ユースケース2 基本フロー2: 入力された判定結果を現在カードへ記録する
                guard var session = try await studySessionRepository.fetch(id: sessionID),
                      let currentCardID = session.currentCardID else {
                    yield(.alert(.showError(.sessionNotFound)))
                    return
                }

                guard case .success = session.recordAnswer(
                    cardID: currentCardID,
                    judgment: judgment,
                    answeredAt: Date()
                ) else {
                    // ユースケース2 例外フローB 2-B,3-B,4-B: 保存失敗時はエラー表示して終了
                    yield(.alert(.showError(.saveFailed)))
                    return
                }

                // ユースケース2 基本フロー3: 残り出題数を再計算する（recordAnswer内で更新）
                try await studySessionRepository.update(session)

                // ユースケース2 分岐フローA 3-A,4-A,5-A: 最終カード判定時は結果保存後に成績一覧へ遷移する
                if session.isFinished {
                    yield(.screen(.navigateToPerformanceList))
                    return
                }

                // ユースケース2 基本フロー4: 次カード画像を表示する
                // ユースケース2 基本フロー5: 更新済み進捗情報を表示する
                guard let nextCardID = session.currentCardID else {
                    yield(.alert(.showError(.cardNotFound)))
                    return
                }
                let cards = try await wordCardRepository.fetchByIDs(ids: [nextCardID])
                guard let nextCard = cards.first else {
                    yield(.alert(.showError(.cardNotFound)))
                    return
                }
                yield(.screen(.showPromptFace))
                yield(.screen(.updateCard(nextCard)))
                yield(.screen(.updateProgress(answeredCount: session.answeredCount, totalCount: session.targetCount.value)))
            } catch {
                // ユースケース2 例外フローB 2-B,3-B,4-B: 保存失敗時はエラー表示して終了
                yield(.alert(.showError(.saveFailed)))
            }
        }
    }

    public func toggleCardFace() async -> AsyncStream<StudySessionViewEffect> {
        EffectStream.make { yield in
            // ユースケース3 基本フロー2: 現在カードを問題表示から意味表示へ切り替える
            // ユースケース3 分岐フローA 2-A: 意味表示→問題表示への戻し分岐はViewState側の現在表示種別で吸収する
            yield(.screen(.showMeaningFace))
        }
    }

    public func handleAlertResult(
        _ alertEffect: StudySessionAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<StudySessionViewEffect> {
        EffectStream.make { _ in
            switch (alertEffect, buttonType) {
            case (_, .cancel), (.showError, .confirm):
                break
            }
        }
    }
}

public enum StudySessionScreenError: Error, Equatable, Sendable {
    case sessionNotFound
    case cardNotFound
    case loadFailed
    case saveFailed
}
