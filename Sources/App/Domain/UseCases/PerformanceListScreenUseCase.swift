// 自動生成
import Foundation

@MainActor
public protocol PerformanceListScreenUseCaseProtocol {
    func fetchPerformanceList() async -> AsyncStream<PerformanceListViewEffect>
    func selectPerformance(sessionID: UUID) async -> AsyncStream<PerformanceListViewEffect>
    func handleAlertResult(
        _ alertEffect: PerformanceListAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<PerformanceListViewEffect>
}

public struct UnimplementedPerformanceListScreenUseCase: PerformanceListScreenUseCaseProtocol {
    public nonisolated init() {}

    public func fetchPerformanceList() async -> AsyncStream<PerformanceListViewEffect> {
        fatalError("fetchPerformanceList is not implemented")
    }

    public func selectPerformance(sessionID: UUID) async -> AsyncStream<PerformanceListViewEffect> {
        fatalError("selectPerformance is not implemented")
    }

    public func handleAlertResult(
        _ alertEffect: PerformanceListAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<PerformanceListViewEffect> {
        fatalError("handleAlertResult is not implemented")
    }
}

@MainActor
public struct PerformanceListScreenUseCase: PerformanceListScreenUseCaseProtocol {
    private let studySessionRepository: any StudySessionRepository

    public init(studySessionRepository: any StudySessionRepository) {
        self.studySessionRepository = studySessionRepository
    }

    public func fetchPerformanceList() async -> AsyncStream<PerformanceListViewEffect> {
        EffectStream.make { yield in
            // ユースケース1 基本フロー2: ローディング状態を表示する
            yield(.screen(.showLoading))
            // ユースケース1 基本フロー4: ローディング状態を非表示にする
            defer { yield(.screen(.hideLoading)) }

            do {
                // ユースケース1 基本フロー3: 学習成績一覧を読み込む
                let summaries = try await studySessionRepository.fetchPerformanceSummaries()
                if summaries.isEmpty {
                    // ユースケース1 分岐フローA 3-A,5-A: 成績0件時は空状態メッセージを表示する
                    yield(.screen(.showEmptyState))
                    return
                }
                yield(.screen(.hideEmptyState))
                // ユースケース1 基本フロー5: 学習成績概要リストを表示する
                yield(.screen(.updateSummaryList(summaries)))
            } catch {
                // ユースケース1 例外フローB 3-B,5-B,6-B: 読み込み失敗時はエラーアラートを表示して終了
                yield(.alert(.showError(.fetchFailed)))
            }
        }
    }

    public func selectPerformance(sessionID: UUID) async -> AsyncStream<PerformanceListViewEffect> {
        EffectStream.make { yield in
            // ユースケース2 基本フロー2: 選択した学習回IDの成績詳細画面へ遷移する
            yield(.screen(.navigateToPerformanceDetail(sessionID: sessionID)))
        }
    }

    public func handleAlertResult(
        _ alertEffect: PerformanceListAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<PerformanceListViewEffect> {
        EffectStream.make { _ in
            switch (alertEffect, buttonType) {
            case (_, .cancel), (.showError, .confirm):
                break
            }
        }
    }
}

public enum PerformanceListError: Error, Equatable, Sendable {
    case fetchFailed
}
