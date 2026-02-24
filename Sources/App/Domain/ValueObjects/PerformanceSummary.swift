// 自動生成
import Foundation

public struct PerformanceSummary: Equatable, Sendable, Identifiable {
    public var id: UUID { sessionID }
    public let sessionID: UUID
    public let studiedAt: Date
    public let gradeLabel: String
    public let correctCount: Int
    public let incorrectCount: Int

    public init(
        sessionID: UUID,
        studiedAt: Date,
        gradeLabel: String,
        correctCount: Int,
        incorrectCount: Int
    ) throws {
        guard correctCount >= 0 else { throw PerformanceSummaryError.invalidCorrectCount }
        guard incorrectCount >= 0 else { throw PerformanceSummaryError.invalidIncorrectCount }
        self.sessionID = sessionID
        self.studiedAt = studiedAt
        self.gradeLabel = gradeLabel
        self.correctCount = correctCount
        self.incorrectCount = incorrectCount
    }
}

public enum PerformanceSummaryError: Error, Equatable, Sendable {
    case invalidCorrectCount
    case invalidIncorrectCount
}
