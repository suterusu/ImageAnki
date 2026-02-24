// 自動生成
import Foundation

public struct MeaningText: Equatable, Sendable {
    public let value: String

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw MeaningTextError.empty }
        self.value = trimmed
    }
}

public enum MeaningTextError: Error, Equatable, Sendable {
    case empty
}
