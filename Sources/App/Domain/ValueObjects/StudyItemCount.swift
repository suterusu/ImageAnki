// 自動生成
import Foundation

public struct StudyItemCount: Equatable, Sendable {
    public static let maxValue = 100

    public let value: Int

    public init(_ value: Int) throws {
        guard value >= 1 else { throw StudyItemCountError.tooSmall }
        guard value <= Self.maxValue else { throw StudyItemCountError.tooLarge }
        self.value = value
    }
}

public enum StudyItemCountError: Error, Equatable, Sendable {
    case tooSmall
    case tooLarge
}
