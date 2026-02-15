// このファイルは自動生成されています

import Foundation

public enum WordChallengeStartScreenViewEffect: Equatable, Sendable {
    case showSelectedGrade(SchoolGrade)
    case showSelectedStudyCount(Int)
    case showInputStudyCount(Int)
    case clearInputError
    case showInputError(WordChallengeStartScreenError)
    case showLoading
    case hideLoading
    case showError(WordChallengeStartScreenError)
    case navigateToStudyCard(UUID)
}

extension WordChallengeStartScreenViewEffect: AppEffectConvertible {
    public func asAppEffect() -> AppEffect {
        .wordChallengeStart(self)
    }
}
