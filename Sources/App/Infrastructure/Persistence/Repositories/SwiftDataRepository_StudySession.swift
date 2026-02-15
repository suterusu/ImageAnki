// このファイルは自動生成されています

import Foundation
import SwiftData

@MainActor
public struct SwiftDataRepository_StudySession: StudySessionRepository {
    private let core: SwiftDataRepository<StudySessionBiMapper>

    public init(context: ModelContext) {
        self.core = SwiftDataRepository(context: context, mapper: StudySessionBiMapper())
    }

    public func fetchAll() async throws -> [StudySession] {
        try await core.fetchAll()
    }

    public func fetch(id: UUID) async throws -> StudySession? {
        try await core.fetch(id: id)
    }

    public func insert(_ domain: StudySession) async throws {
        try await core.insert(domain)
    }

    public func update(_ domain: StudySession) async throws {
        try await core.update(domain)
    }

    public func delete(id: UUID) async throws {
        try await core.delete(id: id)
    }

    public func save(session: StudySession) async throws {
        if try await fetch(id: session.id) == nil {
            try await insert(session)
        } else {
            try await update(session)
        }
    }
}
