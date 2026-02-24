import Foundation
import SwiftData

@MainActor
public final class SwiftDataRepository<Mapper: BiMapper>: RepositoryBaseFunctionProtocol {
    public typealias Domain = Mapper.Domain
    public typealias Persistent = Mapper.Persistent

    let context: ModelContext
    let mapper: Mapper

    public init(context: ModelContext, mapper: Mapper) {
        self.context = context
        self.mapper = mapper
    }

    public func fetchAll() async throws -> [Domain] {
        do {
            let descriptor = FetchDescriptor<Persistent>()
            let persistents = try context.fetch(descriptor)
            return try persistents.map { persistent in
                do {
                    return try mapper.toDomain(persistent)
                } catch {
                    throw RepositoryError.conversionFailed(error)
                }
            }
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.innerError(error)
        }
    }

    public func fetch(id: Domain.ID) async throws -> Domain? {
        do {
            let descriptor = FetchDescriptor<Persistent>()
            guard let persistent = try context.fetch(descriptor).first(where: { $0.id == id }) else {
                return nil
            }
            do {
                return try mapper.toDomain(persistent)
            } catch {
                throw RepositoryError.conversionFailed(error)
            }
        } catch let error as RepositoryError {
            throw error
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
            guard let persistent = try context.fetch(descriptor).first(where: { $0.id == domain.id }) else {
                throw RepositoryError.updateTargetNotFound
            }
            mapper.update(persistent: persistent, from: domain)
            try context.save()
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.innerError(error)
        }
    }

    public func delete(id: Domain.ID) async throws {
        do {
            let descriptor = FetchDescriptor<Persistent>()
            guard let persistent = try context.fetch(descriptor).first(where: { $0.id == id }) else {
                throw RepositoryError.deleteTargetNotFound
            }
            context.delete(persistent)
            try context.save()
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.innerError(error)
        }
    }
}
