// 自動生成
import Foundation

public enum PerformanceDetailScreenEffect: Equatable, Sendable {
    case showLoading
    case hideLoading
    case updateDetail(correctCount: Int, incorrectCount: Int, correctWords: [String], incorrectWords: [String])
    case navigateToPerformanceList
}

public enum PerformanceDetailAlertEffect: Equatable, Sendable {
    case showError(PerformanceDetailError)
}

public typealias PerformanceDetailViewEffect = ViewEffect<PerformanceDetailScreenEffect, PerformanceDetailAlertEffect>

extension PerformanceDetailScreenEffect: AppEffectConvertible {
    public func asAppEffect() -> AppEffect {
        .performanceDetail(self)
    }
}
