// このファイルは自動生成されています

import Foundation
import Observation

@MainActor
@Observable
public final class WordChallengeStartScreenViewState: ViewStateProtocol {
    public typealias Effect = WordChallengeStartScreenViewEffect

    public var selectedGrade: SchoolGrade?
    public var selectedStudyCount: Int?
    public var inputStudyCount: Int?
    public var isLoading: Bool = false
    public var inputErrorMessage: String?
    public var alertMessage: String?

    public init() {}

    public func apply(_ effect: WordChallengeStartScreenViewEffect) {
        switch effect {
        case .showSelectedGrade(let grade):
            selectedGrade = grade
        case .showSelectedStudyCount(let count):
            selectedStudyCount = count
        case .showInputStudyCount(let count):
            inputStudyCount = count
        case .clearInputError:
            inputErrorMessage = nil
        case .showInputError(let error):
            inputErrorMessage = errorMessage(for: error)
        case .showLoading:
            isLoading = true
        case .hideLoading:
            isLoading = false
        case .showError(let error):
            alertMessage = errorMessage(for: error)
        case .navigateToStudyCard:
            break
        }
    }

    private func errorMessage(for error: WordChallengeStartScreenError) -> String {
        switch error {
        case .gradeNotSelected:
            return "学年を選択してください。"
        case .invalidStudyCount:
            return "学習数は1以上で入力してください。"
        case .wordsNotFound:
            return "問題を読み込めませんでした。"
        case .reviewTargetsNotFound:
            return "復習対象が不足しています。"
        case .startFailed:
            return "学習開始に失敗しました。"
        }
    }
}
