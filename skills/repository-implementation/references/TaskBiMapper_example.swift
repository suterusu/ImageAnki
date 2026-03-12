// TaskBiMapper の実装例
// 参考コード

import Foundation

/// TaskとTaskPersistentModelの相互変換を行うMapper
public struct TaskBiMapper: BiMapper {
    public typealias Domain = Task
    public typealias Persistent = TaskPersistentModel

    public init() {}

    /// PersistentModelからドメインモデルへ変換
    /// Value Objectの初期化でバリデーションエラーが発生する可能性があるため throws
    /// データベースに不正なデータが入っている場合、エラーが発生する
    public func toDomain(_ p: TaskPersistentModel) throws -> Task {
        Task(
            id: TaskID(p.id),
            title: try TaskTitle(p.title),
            isCompleted: p.isCompleted
        )
    }

    /// ドメインモデルからPersistentModelへ変換
    /// Value ObjectからプリミティブなStringやUUIDを取り出す
    public func toPersistent(_ d: Task) -> TaskPersistentModel {
        TaskPersistentModel(
            id: d.id.value,
            title: d.title.value,
            isCompleted: d.isCompleted
        )
    }

    /// 既存のPersistentModelをドメインモデルの値で更新
    /// IDは変更しない（不変）、その他のプロパティを更新する
    public func update(persistent: TaskPersistentModel, from domain: Task) {
        // IDは変更しない（Identifiableの不変性を保つ）
        persistent.title = domain.title.value
        persistent.isCompleted = domain.isCompleted
    }
}
