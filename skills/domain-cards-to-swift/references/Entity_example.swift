// Entity 実装例
// Generated from domain card: Task.md
// このファイルは自動生成されています

import Foundation

// MARK: - Entity: Task

// struct + Identifiable + Equatable + Sendable
public struct Task: Identifiable, Equatable, Sendable {
    // SwiftDataの制約 M.Domain.ID == M.Persistent.ID を満たすため、
    // Identifiable.IDをUUIDに明示的に指定
    public typealias ID = UUID

    // idはcomputed propertyとしてUUIDを返す
    public var id: UUID { taskID.value }

    // 内部的にはTaskID値オブジェクトを保持
    public let taskID: TaskID
    public let title: TaskTitle
    public let isCompleted: Bool

    private init(id: TaskID, title: TaskTitle, isCompleted: Bool = false) {
        self.taskID = id
        self.title = title
        self.isCompleted = isCompleted
    }

    // MARK: - ファクトリメソッド（新規作成用）

    // 新規作成時はmakeを使う（IDは内部で生成、引数はプリミティブ型）
    public static func make(title: String, isCompleted: Bool = false) -> Result<Task, TaskError> {
        create(id: UUID(), title: title, isCompleted: isCompleted)
    }

    // 復元時はrestoreを使う（DTOそのものは受け取らない）
    public static func restore(id: UUID, title: String, isCompleted: Bool = false) -> Result<Task, TaskError> {
        create(id: id, title: title, isCompleted: isCompleted)
    }

    private static func create(id: UUID, title: String, isCompleted: Bool) -> Result<Task, TaskError> {
        let titleValue: TaskTitle
        do {
            titleValue = try TaskTitle(title)
        } catch let error as TaskTitleError {
            return .failure(.title(error))
        } catch {
            preconditionFailure("Unexpected TaskTitle error type: \(error)")
        }

        return .success(Task(id: TaskID(value: id), title: titleValue, isCompleted: isCompleted))
    }
}

public enum TaskError: Error, Equatable, Sendable {
    case title(TaskTitleError)
}

// MARK: - ポイント

// 1. struct で定義（値型）
// 2. Identifiable に適合（id プロパティが必須）
// 3. Equatable に適合（テスト可能性）
// 4. Sendable に適合（並行処理安全性）
// 5. すべてのプロパティは public
// 6. Identifiable.ID は UUID に明示的に指定（SwiftData制約対応）
// 7. id は computed property で UUID を返す
// 8. 内部的には taskID: TaskID を stored property として保持
// 9. ドメインルールを持つ属性も値オブジェクト（TaskTitle）を使用
// 10. デフォルト値はinitで指定（例: isCompleted = false）
// 11. 作成が複雑なEntityはinitをprivateにしてファクトリ経由に制限
//     - 引数はプリミティブ型（String等）、内部で値オブジェクトを構成
//     - make: 新規作成（ID自動生成）
//     - restore: 復元（ID指定、DTO非依存）
//     - 戻り値は Result<Entity, EntityError>
//     - EntityError は値オブジェクトのErrorを内包
//
// ※ SwiftDataの制約 M.Domain.ID == M.Persistent.ID を満たすため、
//    この設計が必要。詳細は conventions/swiftdata-constraints.md 参照
