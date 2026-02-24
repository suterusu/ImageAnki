// 自動生成
import Foundation

@MainActor
public protocol PerformanceDetailScreenUseCaseProtocol {
    func fetchPerformanceDetail(sessionID: UUID) async -> AsyncStream<PerformanceDetailViewEffect>
    func backToPerformanceList() async -> AsyncStream<PerformanceDetailViewEffect>
    func handleAlertResult(
        _ alertEffect: PerformanceDetailAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<PerformanceDetailViewEffect>
}

public struct UnimplementedPerformanceDetailScreenUseCase: PerformanceDetailScreenUseCaseProtocol {
    public nonisolated init() {}

    public func fetchPerformanceDetail(sessionID: UUID) async -> AsyncStream<PerformanceDetailViewEffect> {
        fatalError("fetchPerformanceDetail is not implemented")
    }

    public func backToPerformanceList() async -> AsyncStream<PerformanceDetailViewEffect> {
        fatalError("backToPerformanceList is not implemented")
    }

    public func handleAlertResult(
        _ alertEffect: PerformanceDetailAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<PerformanceDetailViewEffect> {
        fatalError("handleAlertResult is not implemented")
    }
}

@MainActor
public struct PerformanceDetailScreenUseCase: PerformanceDetailScreenUseCaseProtocol {
    private let studySessionRepository: any StudySessionRepository
    private let wordCardRepository: any WordCardRepository

    public init(
        studySessionRepository: any StudySessionRepository,
        wordCardRepository: any WordCardRepository
    ) {
        self.studySessionRepository = studySessionRepository
        self.wordCardRepository = wordCardRepository
    }

    public func fetchPerformanceDetail(sessionID: UUID) async -> AsyncStream<PerformanceDetailViewEffect> {
        EffectStream.make { yield in
            // ユースケース1 基本フロー2: ローディング状態を表示する
            yield(.screen(.showLoading))
            // ユースケース1 基本フロー4: ローディング状態を非表示にする
            defer { yield(.screen(.hideLoading)) }

            do {
                // ユースケース1 基本フロー3: 指定された学習回IDの成績詳細を読み込む
                guard let session = try await studySessionRepository.fetch(id: sessionID) else {
                    // ユースケース1 例外フローA 3-A,5-A,6-A: 読み込み失敗時はエラーアラートを表示して終了
                    yield(.alert(.showError(.sessionNotFound)))
                    return
                }

                let answerMap = Dictionary(uniqueKeysWithValues: session.answers.map { ($0.cardID, $0) })
                let cards = try await wordCardRepository.fetchByIDs(ids: Array(answerMap.keys))

                var correctWords: [String] = []
                var incorrectWords: [String] = []
                for card in cards {
                    guard let answer = answerMap[card.id] else { continue }
                    if answer.judgment == .correct {
                        correctWords.append(card.promptText.value)
                    } else {
                        incorrectWords.append(card.promptText.value)
                    }
                }

                yield(
                    .screen(
                        .updateDetail(
                            // ユースケース1 基本フロー5: 正解数と不正解数を表示する
                            // ユースケース1 基本フロー6: 正解一覧を表示する
                            // ユースケース1 基本フロー7: 不正解一覧を表示する
                            correctCount: session.correctCount(),
                            incorrectCount: session.incorrectCount(),
                            correctWords: correctWords,
                            incorrectWords: incorrectWords
                        )
                    )
                )
            } catch {
                // ユースケース1 例外フローA 3-A,5-A,6-A: 読み込み失敗時はエラーアラートを表示して終了
                yield(.alert(.showError(.fetchFailed)))
            }
        }
    }

    public func backToPerformanceList() async -> AsyncStream<PerformanceDetailViewEffect> {
        EffectStream.make { yield in
            // ユースケース2 基本フロー2: 成績一覧画面へ遷移する
            yield(.screen(.navigateToPerformanceList))
        }
    }

    public func handleAlertResult(
        _ alertEffect: PerformanceDetailAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<PerformanceDetailViewEffect> {
        EffectStream.make { _ in
            switch (alertEffect, buttonType) {
            case (_, .cancel), (.showError, .confirm):
                break
            }
        }
    }
}

public enum PerformanceDetailError: Error, Equatable, Sendable {
    case sessionNotFound
    case fetchFailed
}
