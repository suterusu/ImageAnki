import Foundation
@testable import App

struct RepositoryForcedError: Error {}

@MainActor
final class WordRepository_Failing: WordRepository {
    typealias Domain = Word

    func fetchAll() async throws -> [Word] { throw RepositoryForcedError() }
    func fetch(id: UUID) async throws -> Word? { throw RepositoryForcedError() }
    func insert(_ domain: Word) async throws { throw RepositoryForcedError() }
    func update(_ domain: Word) async throws { throw RepositoryForcedError() }
    func delete(id: UUID) async throws { throw RepositoryForcedError() }
    func fetchByGrade(grade: SchoolGrade, limit: Int) async throws -> [Word] { throw RepositoryForcedError() }
    func fetchByIDs(ids: [UUID]) async throws -> [Word] { throw RepositoryForcedError() }
}

@MainActor
final class StudySessionRepository_Failing: StudySessionRepository {
    typealias Domain = StudySession

    func fetchAll() async throws -> [StudySession] { throw RepositoryForcedError() }
    func fetch(id: UUID) async throws -> StudySession? { throw RepositoryForcedError() }
    func insert(_ domain: StudySession) async throws { throw RepositoryForcedError() }
    func update(_ domain: StudySession) async throws { throw RepositoryForcedError() }
    func delete(id: UUID) async throws { throw RepositoryForcedError() }
    func save(session: StudySession) async throws { throw RepositoryForcedError() }
}
