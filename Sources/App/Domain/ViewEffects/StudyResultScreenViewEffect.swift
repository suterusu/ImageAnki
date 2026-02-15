// このファイルは自動生成されています

import Foundation

public enum StudyResultScreenViewEffect: Equatable, Sendable {
    case showLoading
    case hideLoading
    case showError(StudyResultScreenError)
    case showSummary(correctCount: Int, incorrectCount: Int)
    case showAnswers([StudyAnswer])
    case navigateToProblemList
    case navigateToStudyCard(UUID)
}

extension StudyResultScreenViewEffect: AppEffectConvertible {
    public func asAppEffect() -> AppEffect {
        .studyResult(self)
    }
}
