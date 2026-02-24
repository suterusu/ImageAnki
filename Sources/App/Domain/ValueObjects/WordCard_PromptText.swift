// 自動生成
import Foundation

public struct PromptText: Equatable, Sendable {
    public let value: String

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw PromptTextError.empty }
        self.value = trimmed
    }
}

public enum PromptTextError: Error, Equatable, Sendable {
    case empty
}
