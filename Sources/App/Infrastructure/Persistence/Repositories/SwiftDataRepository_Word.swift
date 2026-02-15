// このファイルは自動生成されています

import Foundation
import SwiftData

@MainActor
public struct SwiftDataRepository_Word: WordRepository {
    private let core: SwiftDataRepository<WordBiMapper>

    public init(context: ModelContext) {
        self.core = SwiftDataRepository(context: context, mapper: WordBiMapper())
    }

    public func fetchAll() async throws -> [Word] {
        try await core.fetchAll()
    }

    public func fetch(id: UUID) async throws -> Word? {
        try await core.fetch(id: id)
    }

    public func insert(_ domain: Word) async throws {
        try await core.insert(domain)
    }

    public func update(_ domain: Word) async throws {
        try await core.update(domain)
    }

    public func delete(id: UUID) async throws {
        try await core.delete(id: id)
    }

    public func fetchByGrade(grade: SchoolGrade, limit: Int) async throws -> [Word] {
        do {
            let descriptor = FetchDescriptor<WordPersistentModel>()
            let persistents = try core.context.fetch(descriptor)
            let filtered = persistents
                .filter { $0.gradeRawValue == grade.rawValue }
                .prefix(limit)
            return try filtered.map { try core.mapper.toDomain($0) }
        } catch {
            throw RepositoryError.innerError(error)
        }
    }

    public func fetchByIDs(ids: [UUID]) async throws -> [Word] {
        do {
            let descriptor = FetchDescriptor<WordPersistentModel>()
            let persistents = try core.context.fetch(descriptor)
            let idSet = Set(ids)
            let filtered = persistents.filter { idSet.contains($0.id) }
            return try filtered.map { try core.mapper.toDomain($0) }
        } catch {
            throw RepositoryError.innerError(error)
        }
    }
}
