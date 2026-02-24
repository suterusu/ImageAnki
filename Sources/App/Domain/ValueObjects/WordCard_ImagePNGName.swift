// 自動生成
import Foundation

public struct ImagePNGName: Equatable, Sendable {
    public let value: String

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ImagePNGNameError.empty }
        guard trimmed.lowercased().hasSuffix(".png") else { throw ImagePNGNameError.invalidExtension }
        self.value = trimmed
    }
}

public enum ImagePNGNameError: Error, Equatable, Sendable {
    case empty
    case invalidExtension
}
