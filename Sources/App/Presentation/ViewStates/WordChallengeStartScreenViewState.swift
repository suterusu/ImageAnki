import Foundation
import Observation

@MainActor
@Observable
public final class WordChallengeStartScreenViewState: ViewStateProtocol {
    public var selectedGrade: SchoolGrade = .junior1
    public var inputItemCountText: String = ""
    public var isInputErrorVisible: Bool = false
    public var isLoading: Bool = false
    public var emptyStateMessage: String?
    public var alertState: AlertState<WordChallengeStartAlertEffect>?

    public init() {}

    public func apply(_ effect: WordChallengeStartViewEffect) {
        switch effect {
        case .screen(let screenEffect):
            switch screenEffect {
            case .showLoading:
                isLoading = true
            case .hideLoading:
                isLoading = false
            case .showEmptyState(let message):
                emptyStateMessage = message
            case .hideEmptyState:
                emptyStateMessage = nil
            case .clearInputError:
                isInputErrorVisible = false
            case .showInputError:
                isInputErrorVisible = true
            case .navigateToStudySession:
                break
            }
        case .alert(let alertEffect):
            alertState = makeAlertState(from: alertEffect)
        }
    }

    private func makeAlertState(from effect: WordChallengeStartAlertEffect) -> AlertState<WordChallengeStartAlertEffect> {
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

    private func errorMessage(for error: WordChallengeStartError) -> String {
        switch error {
        case .invalidStudyItemCount:
            return "学習数は1〜100の整数で入力してください。"
        case .fetchCardsFailed:
            return "単語カードの読み込みに失敗しました。"
        case .reviewSelectionFailed:
            return "復習対象カードの選定に失敗しました。"
        case .startSessionFailed:
            return "学習セッションを開始できませんでした。"
        }
    }
}
