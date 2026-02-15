// このファイルは自動生成されています

import Foundation
import Observation

@MainActor
@Observable
public final class StudyResultScreenViewState: ViewStateProtocol {
    public typealias Effect = StudyResultScreenViewEffect

    public var sessionID: UUID?
    public var correctCount: Int = 0
    public var incorrectCount: Int = 0
    public var answers: [StudyAnswer] = []
    public var isLoading: Bool = false
    public var alertMessage: String?

    public init() {}

    public func apply(_ effect: StudyResultScreenViewEffect) {
        switch effect {
        case .showLoading:
            isLoading = true
        case .hideLoading:
            isLoading = false
        case .showError(let error):
            alertMessage = errorMessage(for: error)
        case .showSummary(let correctCount, let incorrectCount):
            self.correctCount = correctCount
            self.incorrectCount = incorrectCount
        case .showAnswers(let answers):
            self.answers = answers
        case .navigateToProblemList:
            break
        case .navigateToStudyCard:
            break
        }
    }

    private func errorMessage(for error: StudyResultScreenError) -> String {
        switch error {
        case .sessionNotFound:
            return "学習結果が見つかりません。"
        case .loadFailed:
            return "学習結果の読み込みに失敗しました。"
        case .reviewStartFailed:
            return "復習学習を開始できませんでした。"
        }
    }
}
