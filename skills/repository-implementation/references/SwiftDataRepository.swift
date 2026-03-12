// SwiftDataRepository ジェネリック基底クラス
// 参考コード

import Foundation
import SwiftData

/// Repository操作に関するエラー
public enum RepositoryError: Error {
    /// 更新対象のエンティティが見つからなかった
    /// - Parameters:
    ///   - id: 検索対象のID（文字列表現）
    ///   - entityType: エンティティの型名
    case updateTargetNotFound(id: String, entityType: String)

    /// 削除対象のエンティティが見つからなかった
    /// - Parameters:
    ///   - id: 検索対象のID（文字列表現）
    ///   - entityType: エンティティの型名
    case deleteTargetNotFound(id: String, entityType: String)

    /// PersistentModelからドメインモデルへの変換に失敗した
    /// - Parameters:
    ///   - persistentType: PersistentModelの型名
    ///   - domainType: ドメインモデルの型名
    ///   - underlyingError: 変換失敗の原因となったエラー
    case conversionFailed(persistentType: String, domainType: String, underlyingError: Error)
}

/// SwiftDataを使用したジェネリックなRepositoryの基底実装
/// BiMapperを使ってドメインモデルとPersistentModelを相互変換する
@MainActor
public final class SwiftDataRepository<M: BiMapper>: RepositoryBaseFunctionProtocol
where M.Domain.ID == M.Persistent.ID {
    public typealias Domain = M.Domain
    private typealias Persistent = M.Persistent

    internal let context: ModelContext
    private let mapper: M

    public init(context: ModelContext, mapper: M) {
        self.context = context
        self.mapper = mapper
    }

    // MARK: - RepositoryBaseFunctionProtocol

    public func fetchAll() async throws -> [M.Domain] {
        let descriptor = FetchDescriptor<M.Persistent>()
        let persistentModels = try context.fetch(descriptor)

        return try persistentModels.map { persistent in
            do {
                return try mapper.toDomain(persistent)
            } catch {
                throw RepositoryError.conversionFailed(
                    persistentType: String(describing: M.Persistent.self),
                    domainType: String(describing: M.Domain.self),
                    underlyingError: error
                )
            }
        }
    }

    public func fetch(id: Domain.ID) async throws -> M.Domain? {
        let descriptor = FetchDescriptor<M.Persistent>()
        let all = try context.fetch(descriptor)

        guard let persistent = all.first(where: { $0.id == id }) else {
            return nil
        }

        do {
            return try mapper.toDomain(persistent)
        } catch {
            throw RepositoryError.conversionFailed(
                persistentType: String(describing: M.Persistent.self),
                domainType: String(describing: M.Domain.self),
                underlyingError: error
            )
        }
    }

    public func insert(_ domain: M.Domain) async throws {
        let entity = mapper.toPersistent(domain)
        context.insert(entity)
        try context.save()
    }

    public func update(_ domain: M.Domain) async throws {
        let descriptor = FetchDescriptor<M.Persistent>()
        let all = try context.fetch(descriptor)
        guard let target = all.first(where: { $0.id == domain.id }) else {
            throw RepositoryError.updateTargetNotFound(
                id: "\(domain.id)",
                entityType: String(describing: M.Domain.self)
            )
        }
        mapper.update(persistent: target, from: domain)
        try context.save()
    }

    public func delete(id: Domain.ID) async throws {
        let descriptor = FetchDescriptor<M.Persistent>()
        let all = try context.fetch(descriptor)
        guard let target = all.first(where: { $0.id == id }) else {
            throw RepositoryError.deleteTargetNotFound(
                id: "\(id)",
                entityType: String(describing: M.Domain.self)
            )
        }
        context.delete(target)
        try context.save()
    }
}
