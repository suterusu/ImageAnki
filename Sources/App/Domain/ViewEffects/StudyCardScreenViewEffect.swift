// このファイルは自動生成されています

import Foundation

public enum StudyCardScreenViewEffect: Equatable, Sendable {
    case showLoading
    case hideLoading
    case showError(StudyCardScreenError)
    case showCard(Word)
    case updateProgress(current: Int, total: Int)
    case setCardFace(isAnswerSide: Bool)
    case navigateToStudyResult(UUID)
}

extension StudyCardScreenViewEffect: AppEffectConvertible {
    public func asAppEffect() -> AppEffect {
        .studyCard(self)
    }
}
