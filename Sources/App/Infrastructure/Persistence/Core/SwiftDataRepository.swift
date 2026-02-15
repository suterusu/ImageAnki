// このファイルは自動生成されています

import Foundation
import SwiftData

@MainActor
public final class SwiftDataRepository<Mapper: BiMapper>: RepositoryBaseFunctionProtocol where Mapper.Domain.ID == Mapper.Persistent.ID {
    public typealias Domain = Mapper.Domain
    public typealias Persistent = Mapper.Persistent

    public let context: ModelContext
    public let mapper: Mapper

    public init(context: ModelContext, mapper: Mapper) {
        self.context = context
        self.mapper = mapper
    }

    public func fetchAll() async throws -> [Domain] {
        do {
            let descriptor = FetchDescriptor<Persistent>()
            let persistents = try context.fetch(descriptor)
            return try persistents.map { try mapper.toDomain($0) }
        } catch {
            throw RepositoryError.innerError(error)
        }
    }

    public func fetch(id: Domain.ID) async throws -> Domain? {
        do {
            let descriptor = FetchDescriptor<Persistent>()
            let persistents = try context.fetch(descriptor)
            guard let persistent = persistents.first(where: { $0.id == id }) else {
                return nil
            }
            return try mapper.toDomain(persistent)
        } catch {
            throw RepositoryError.innerError(error)
        }
    }

    public func insert(_ domain: Domain) async throws {
        do {
            let persistent = mapper.toPersistent(domain)
            context.insert(persistent)
            try context.save()
        } catch {
            throw RepositoryError.innerError(error)
        }
    }

    public func update(_ domain: Domain) async throws {
        do {
            let descriptor = FetchDescriptor<Persistent>()
            let persistents = try context.fetch(descriptor)
            guard let target = persistents.first(where: { $0.id == domain.id }) else {
                throw SwiftDataRepositoryError.notFound
            }
            mapper.update(persistent: target, from: domain)
            try context.save()
        } catch {
            throw RepositoryError.innerError(error)
        }
    }

    public func delete(id: Domain.ID) async throws {
        do {
            let descriptor = FetchDescriptor<Persistent>()
            let persistents = try context.fetch(descriptor)
            guard let target = persistents.first(where: { $0.id == id }) else {
                throw SwiftDataRepositoryError.notFound
            }
            context.delete(target)
            try context.save()
        } catch {
            throw RepositoryError.innerError(error)
        }
    }
}

private enum SwiftDataRepositoryError: Error {
    case notFound
}
