// このファイルは自動生成されています

import Foundation
import Observation

@MainActor
@Observable
public final class StudyCardScreenViewState: ViewStateProtocol {
    public typealias Effect = StudyCardScreenViewEffect

    public var currentCard: Word?
    public var currentIndex: Int = 0
    public var totalCount: Int = 0
    public var isAnswerSide: Bool = false
    public var isLoading: Bool = false
    public var alertMessage: String?

    public init() {}

    public func apply(_ effect: StudyCardScreenViewEffect) {
        switch effect {
        case .showLoading:
            isLoading = true
        case .hideLoading:
            isLoading = false
        case .showError(let error):
            alertMessage = errorMessage(for: error)
        case .showCard(let card):
            currentCard = card
        case .updateProgress(let current, let total):
            currentIndex = current
            totalCount = total
        case .setCardFace(let isAnswerSide):
            self.isAnswerSide = isAnswerSide
        case .navigateToStudyResult:
            break
        }
    }

    private func errorMessage(for error: StudyCardScreenError) -> String {
        switch error {
        case .sessionNotFound:
            return "学習セッションが見つかりません。"
        case .cardsNotFound:
            return "出題カードが見つかりません。"
        case .saveFailed:
            return "判定の保存に失敗しました。"
        case .loadFailed:
            return "カード読み込みに失敗しました。"
        }
    }
}
