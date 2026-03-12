// Repository 実装例
// Generated from domain card: TaskRepository.md
// このファイルは自動生成されています

import Foundation

// MARK: - Repository: TaskRepository

// protocol + RepositoryBaseFunctionProtocol + async throws
// RepositoryはCRUD操作とクエリのみを提供
// ビジネスロジック（create, update, toggleCompleteなど）はUseCase層で実装
public protocol TaskRepository: RepositoryBaseFunctionProtocol {
    // 基本CRUD操作はRepositoryBaseFunctionProtocolから継承される：
    // - func fetchAll() async throws -> [Domain]
    // - func fetch(id: Domain.ID) async throws -> Domain?
    // - func insert(_ domain: Domain) async throws
    // - func delete(id: Domain.ID) async throws

    typealias Domain = Task

    // MARK: - クエリ系メソッド（必要に応じて追加）
    // SwiftDataRepository の extension で実装される

    /// 完了済みのタスクを取得する（例）
    // func fetchCompleted() async throws -> [Task]

    /// タイトルでソートされたタスクを取得する（例）
    // func fetchSortedByTitle() async throws -> [Task]
}

// MARK: - ポイント

// 1. protocol で定義（インターフェース）
// 2. RepositoryBaseFunctionProtocol を継承
//    - 基本CRUD操作が自動的に含まれる
//    - fetchAll(), fetch(id:), insert(_:), delete(id:)
// 3. typealias Domain でエンティティ型を指定
//    - RepositoryBaseFunctionProtocol の associatedtype を解決
// 4. すべてのメソッドは async throws
//    - 非同期処理（async）
//    - エラーを投げる可能性（throws）
// 6. ビジネスロジックは含めない
//    - タスク作成、更新、完了切り替えなどはUseCase層で実装
//    - Repositoryは純粋な永続化のみを担当
// 7. パラメータは値オブジェクトを使用
//    - TaskID など（Domain.IDとして解決される）
// 8. 戻り値はエンティティまたはエンティティの配列
//    - Task, [Task]
// 9. 存在しない可能性がある場合はオプショナル
//    - fetch(id:) -> Task?
// 10. クエリ系メソッドは必要に応じて追加
//     - fetchCompleted(), fetchSortedByTitle() など
// 11. 実装は SwiftDataRepository<TaskBiMapper> で行われる
//     - 基本CRUD: RepositoryBaseFunctionProtocol を通じて提供
//     - クエリ系: extension で追加実装
