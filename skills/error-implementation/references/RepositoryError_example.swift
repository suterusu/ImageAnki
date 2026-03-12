import Foundation

/// Repository層で発生するエラー
public enum RepositoryError: Error, Sendable {
    /// Infrastructure層（SwiftDataなど）のエラー
    case innerError(Error)

    /// バリデーションエラー
    case validation(String)
}

// MARK: - LocalizedError

extension RepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .innerError(let error):
            return "永続化層でエラーが発生しました: \(error.localizedDescription)"

        case .validation(let message):
            return "バリデーションエラー: \(message)"
        }
    }
}

// MARK: - 使用例

/*
// Repository実装でInfrastructure層のエラーをラップ
func save() async throws {
    do {
        try modelContext.save()
    } catch {
        throw RepositoryError.innerError(error)
    }
}

// バリデーションエラーのスロー
func validate(title: String) throws {
    if title.isEmpty {
        throw RepositoryError.validation("タイトルは必須です")
    }
}
*/
