import Foundation
import Observation

@MainActor
@Observable
public final class PerformanceListScreenViewState: ViewStateProtocol {
    public var summaries: [PerformanceSummary] = []
    public var selectedSessionID: UUID?
    public var isLoading: Bool = false
    public var isEmptyStateVisible: Bool = false
    public var alertState: AlertState<PerformanceListAlertEffect>?

    public init() {}

    public func apply(_ effect: PerformanceListViewEffect) {
        switch effect {
        case .screen(let screenEffect):
            switch screenEffect {
            case .showLoading:
                isLoading = true
            case .hideLoading:
                isLoading = false
            case .showEmptyState:
                isEmptyStateVisible = true
            case .hideEmptyState:
                isEmptyStateVisible = false
            case .updateSummaryList(let summaries):
                self.summaries = summaries
            case .navigateToPerformanceDetail(let sessionID):
                selectedSessionID = sessionID
            }
        case .alert(let alertEffect):
            alertState = makeAlertState(from: alertEffect)
        }
    }

    private func makeAlertState(from effect: PerformanceListAlertEffect) -> AlertState<PerformanceListAlertEffect> {
        switch effect {
        case .showError(let error):
            return AlertState(
                alertEffect: .showError(error),
                alertType: .informational,
                title: "エラー",
                message: errorMessage(for: error),
                buttonTitle: "OK",
                cancelButtonTitle: nil
            )
        }
    }

    private func errorMessage(for error: PerformanceListError) -> String {
        switch error {
        case .fetchFailed:
            return "学習成績一覧の読み込みに失敗しました。"
        }
    }
}
