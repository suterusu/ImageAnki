// Value Object 実装例
// Generated from domain card: TaskTitle.md
// このファイルは自動生成されています

import Foundation

// MARK: - Value Object (制約あり): TaskTitle

// struct + Equatable + Sendable
// 制約がある場合は throws init
public struct TaskTitle: Equatable, Sendable {
    public let value: String

    public init(_ value: String) throws {
        guard !value.isEmpty else {
            throw TaskTitleError.empty
        }
        guard value.count <= 10 else {
            throw TaskTitleError.tooLong
        }
        self.value = value
    }
}

public enum TaskTitleError: Error {
    case empty
    case tooLong
}

// MARK: - ポイント

// 1. struct で定義（値型）
// 2. Equatable に適合（比較可能）
// 3. Sendable に適合（並行処理安全性）
// 4. すべてのプロパティは public
// 5. value プロパティで内部値を保持
// 6. 制約がある場合は throws init
//    - 空文字チェック、長さチェック、フォーマットチェックなど
// 7. 制約がない場合は通常の init
// 8. Hashable は必要に応じて適合（Dictionaryのキーとして使う場合など）
// 9. 制約がある場合はエラー型を定義