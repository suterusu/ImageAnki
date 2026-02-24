import Foundation
import Observation

@MainActor
@Observable
public final class PerformanceDetailScreenViewState: ViewStateProtocol {
    public let sessionID: UUID
    public var correctCount: Int = 0
    public var incorrectCount: Int = 0
    public var correctWords: [String] = []
    public var incorrectWords: [String] = []
    public var isLoading: Bool = false
    public var alertState: AlertState<PerformanceDetailAlertEffect>?

    public init(sessionID: UUID) {
        self.sessionID = sessionID
    }

    public func apply(_ effect: PerformanceDetailViewEffect) {
        switch effect {
        case .screen(let screenEffect):
            switch screenEffect {
            case .showLoading:
                isLoading = true
            case .hideLoading:
                isLoading = false
            case let .updateDetail(correctCount, incorrectCount, correctWords, incorrectWords):
                self.correctCount = correctCount
                self.incorrectCount = incorrectCount
                self.correctWords = correctWords
                self.incorrectWords = incorrectWords
            case .navigateToPerformanceList:
                break
            }
        case .alert(let alertEffect):
            alertState = makeAlertState(from: alertEffect)
        }
    }

    private func makeAlertState(from effect: PerformanceDetailAlertEffect) -> AlertState<PerformanceDetailAlertEffect> {
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

    private func errorMessage(for error: PerformanceDetailError) -> String {
        switch error {
        case .sessionNotFound:
            return "学習回が見つかりません。"
        case .fetchFailed:
            return "成績詳細の読み込みに失敗しました。"
        }
    }
}
