import Foundation
import ImageAnki

@MainActor
final class WordCardRepository_Failing: WordCardRepository {
    typealias Domain = WordCard

    func fetchAll() async throws -> [WordCard] { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func fetch(id: UUID) async throws -> WordCard? { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func insert(_ domain: WordCard) async throws { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func update(_ domain: WordCard) async throws { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func delete(id: UUID) async throws { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func fetchByGrade(grade: SchoolGrade, count: StudyItemCount) async throws -> [WordCard] { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func fetchByIDs(ids: [UUID]) async throws -> [WordCard] { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
}

@MainActor
final class StudySessionRepository_Failing: StudySessionRepository {
    typealias Domain = StudySession

    func fetchAll() async throws -> [StudySession] { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func fetch(id: UUID) async throws -> StudySession? { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func insert(_ domain: StudySession) async throws { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func update(_ domain: StudySession) async throws { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func delete(id: UUID) async throws { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
    func fetchPerformanceSummaries() async throws -> [PerformanceSummary] { throw RepositoryError.innerError(NSError(domain: "test", code: -1)) }
}
