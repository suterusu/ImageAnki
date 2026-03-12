// SwiftDataRepository_Task の実装例
// 参考コード

import Foundation
import SwiftData

/// SwiftDataRepositoryをTaskRepository専用に拡張
/// TaskRepositoryプロトコルのクエリ系メソッドを実装
/// 基本CRUD（fetchAll, fetch, insert, delete）は RepositoryBaseFunctionProtocol から提供される
extension SwiftDataRepository: TaskRepository where M == TaskBiMapper {
    // MARK: - クエリ系メソッド（例）

    /// 完了済みのタスクを取得
    /// - Returns: 完了済みタスクの配列
    public func fetchCompleted() async throws -> [Task] {
        var descriptor = FetchDescriptor<TaskPersistentModel>(
            predicate: #Predicate { $0.isCompleted == true }
        )
        descriptor.sortBy = [SortDescriptor(\.title)]

        return try context.fetch(descriptor).map { mapper.toDomain($0) }
    }

    /// タイトルでソートされたタスクを取得
    /// - Returns: タイトル順にソートされたタスクの配列
    public func fetchSortedByTitle() async throws -> [Task] {
        var descriptor = FetchDescriptor<TaskPersistentModel>()
        descriptor.sortBy = [SortDescriptor(\.title)]

        return try context.fetch(descriptor).map { mapper.toDomain($0) }
    }
}

// MARK: - 注意
// - create, update, toggleComplete などのビジネスロジックは UseCase 層で実装
// - Repository はデータの取得・永続化のみを担当
// 例: タスク作成（UseCase層）
//   let task = Task(id: TaskID(UUID()), title: title, isCompleted: false)
//   try await repository.insert(task)
// 例: タスク更新（UseCase層）
//   guard var task = try await repository.fetch(id: id) else { throw ... }
//   task.title = newTitle
//   try await repository.insert(task)  // insertで上書き
