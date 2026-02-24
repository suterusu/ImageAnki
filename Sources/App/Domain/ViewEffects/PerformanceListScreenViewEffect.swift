// 自動生成
import Foundation

public enum PerformanceListScreenEffect: Equatable, Sendable {
    case showLoading
    case hideLoading
    case showEmptyState
    case hideEmptyState
    case updateSummaryList([PerformanceSummary])
    case navigateToPerformanceDetail(sessionID: UUID)
}

public enum PerformanceListAlertEffect: Equatable, Sendable {
    case showError(PerformanceListError)
}

public typealias PerformanceListViewEffect = ViewEffect<PerformanceListScreenEffect, PerformanceListAlertEffect>

extension PerformanceListScreenEffect: AppEffectConvertible {
    public func asAppEffect() -> AppEffect {
        .performanceList(self)
    }
}
