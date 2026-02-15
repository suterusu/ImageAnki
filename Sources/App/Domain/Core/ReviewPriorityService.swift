// このファイルは自動生成されています

import Foundation

public protocol ReviewPriorityService: Sendable {
    func selectReviewWords(
        sessions: [StudySession],
        from words: [Word],
        limit: Int
    ) -> [Word]
}

public struct DefaultReviewPriorityService: ReviewPriorityService {
    public init() {}

    public func selectReviewWords(
        sessions: [StudySession],
        from words: [Word],
        limit: Int
    ) -> [Word] {
        let incorrectWordIDs = sessions
            .flatMap(\.answers)
            .filter { $0.judgment == .incorrect }
            .map(\.wordID)

        let prioritized = words.filter { incorrectWordIDs.contains($0.id) }
        if prioritized.count >= limit {
            return Array(prioritized.prefix(limit))
        }

        let remaining = words.filter { !incorrectWordIDs.contains($0.id) }
        return Array((prioritized + remaining).prefix(limit))
    }
}
