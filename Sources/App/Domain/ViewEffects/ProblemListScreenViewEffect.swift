// このファイルは自動生成されています

import Foundation

public enum ProblemListScreenViewEffect: Equatable, Sendable {
    case showLoading
    case hideLoading
    case showError(ProblemListScreenError)
    case showEmptyState
    case showHistoryList([StudySession])
    case navigateToStudyResult(UUID)
}

extension ProblemListScreenViewEffect: AppEffectConvertible {
    public func asAppEffect() -> AppEffect {
        .problemList(self)
    }
}
