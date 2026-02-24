// 自動生成
import Foundation

public enum StudySessionScreenEffect: Equatable, Sendable {
    case showLoading
    case hideLoading
    case showPromptFace
    case showMeaningFace
    case updateCard(WordCard)
    case updateProgress(answeredCount: Int, totalCount: Int)
    case navigateToPerformanceList
}

public enum StudySessionAlertEffect: Equatable, Sendable {
    case showError(StudySessionScreenError)
}

public typealias StudySessionViewEffect = ViewEffect<StudySessionScreenEffect, StudySessionAlertEffect>

extension StudySessionScreenEffect: AppEffectConvertible {
    public func asAppEffect() -> AppEffect {
        .studySession(self)
    }
}
