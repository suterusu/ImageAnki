// TaskPersistentModel の実装例
// 参考コード

import SwiftData
import Foundation

/// タスクのPersistentModel
/// SwiftDataでのデータ永続化に使用
/// ドメインのTaskエンティティとは型を分離し、プリミティブ型のみを使用
@Model
final class TaskPersistentModel: Identifiable {
    /// タスクの識別子（UUID）
    /// ドメインのTaskID.valueと一致
    var id: UUID

    /// タスクのタイトル（String）
    /// ドメインのTaskTitle.valueと一致
    var title: String

    /// タスクの完了状態
    var isCompleted: Bool

    init(id: UUID, title: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
