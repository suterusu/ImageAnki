// Repository基本機能プロトコル
// 参考コード

import Foundation

/// Repository基本機能を定義するプロトコル
/// すべてのRepositoryが持つべき基本的なCRUD操作を定義
public protocol RepositoryBaseFunctionProtocol {
    associatedtype Domain: Identifiable

    /// すべてのエンティティを取得
    func fetchAll() async throws -> [Domain]

    /// IDでエンティティを取得
    func fetch(id: Domain.ID) async throws -> Domain?

    /// エンティティを挿入
    func insert(_ domain: Domain) async throws

    /// IDでエンティティを削除
    func delete(id: Domain.ID) async throws
}
