// 自動生成
import Foundation

public protocol ReviewSelectionService: Sendable {
    func selectReviewCardIDs(
        sessions: [StudySession],
        targetCount: StudyItemCount,
        now: Date
    ) throws -> [UUID]
}

public struct DefaultReviewSelectionService: ReviewSelectionService {
    public init() {}

    public func selectReviewCardIDs(
        sessions: [StudySession],
        targetCount: StudyItemCount,
        now: Date
    ) throws -> [UUID] {
        _ = now
        let incorrectIDs = sessions
            .flatMap(\.answers)
            .filter { $0.judgment == .incorrect }
            .sorted { $0.answeredAt > $1.answeredAt }
            .map(\.cardID)

        var seen = Set<UUID>()
        let unique = incorrectIDs.filter { seen.insert($0).inserted }
        return Array(unique.prefix(targetCount.value))
    }
}
