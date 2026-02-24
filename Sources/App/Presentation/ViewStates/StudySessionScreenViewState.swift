import Foundation
import Observation

public enum StudyCardFace: Sendable {
    case prompt
    case meaning
}

@MainActor
@Observable
public final class StudySessionScreenViewState: ViewStateProtocol {
    public var currentCardID: UUID?
    public var currentCardFace: StudyCardFace = .prompt
    public var currentCardPromptText: String = ""
    public var currentCardMeaningText: String = ""
    public var currentCardImageName: String = ""
    public var progressText: String = "0/0"
    public var isLoading: Bool = false
    public var alertState: AlertState<StudySessionAlertEffect>?

    public init() {}

    public func apply(_ effect: StudySessionViewEffect) {
        switch effect {
        case .screen(let screenEffect):
            switch screenEffect {
            case .showLoading:
                isLoading = true
            case .hideLoading:
                isLoading = false
            case .showPromptFace:
                currentCardFace = .prompt
            case .showMeaningFace:
                currentCardFace = .meaning
            case .updateCard(let card):
                currentCardID = card.id
                currentCardPromptText = card.promptText.value
                currentCardMeaningText = card.meaningText.value
                currentCardImageName = card.imagePNGName.value
            case .updateProgress(let answeredCount, let totalCount):
                progressText = "\(answeredCount)/\(totalCount)"
            case .navigateToPerformanceList:
                break
            }
        case .alert(let alertEffect):
            alertState = makeAlertState(from: alertEffect)
        }
    }

    private func makeAlertState(from effect: StudySessionAlertEffect) -> AlertState<StudySessionAlertEffect> {
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

    private func errorMessage(for error: StudySessionScreenError) -> String {
        switch error {
        case .sessionNotFound:
            return "学習セッションが見つかりません。"
        case .cardNotFound:
            return "表示対象カードが見つかりません。"
        case .loadFailed:
            return "学習セッションの読み込みに失敗しました。"
        case .saveFailed:
            return "判定結果の保存に失敗しました。"
        }
    }
}
