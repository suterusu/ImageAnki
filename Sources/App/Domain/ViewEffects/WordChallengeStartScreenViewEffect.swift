// 自動生成
import Foundation

public enum WordChallengeStartScreenEffect: Equatable, Sendable {
    case showLoading
    case hideLoading
    case showEmptyState(String)
    case hideEmptyState
    case clearInputError
    case showInputError
    case navigateToStudySession(sessionID: UUID)
}

public enum WordChallengeStartAlertEffect: Equatable, Sendable {
    case showError(WordChallengeStartError)
}

public typealias WordChallengeStartViewEffect = ViewEffect<WordChallengeStartScreenEffect, WordChallengeStartAlertEffect>

extension WordChallengeStartScreenEffect: AppEffectConvertible {
    public func asAppEffect() -> AppEffect {
        .wordChallengeStart(self)
    }
}
