// このファイルは自動生成されています

import Foundation

public struct StudySessionSummary: Equatable, Sendable {
    public let correctCount: Int
    public let incorrectCount: Int

    public init(correctCount: Int, incorrectCount: Int) throws {
        guard correctCount >= 0 else { throw StudySessionSummaryError.correctCountNegative }
        guard incorrectCount >= 0 else { throw StudySessionSummaryError.incorrectCountNegative }
        self.correctCount = correctCount
        self.incorrectCount = incorrectCount
    }
}

public enum StudySessionSummaryError: Error, Equatable, Sendable {
    case correctCountNegative
    case incorrectCountNegative
}
