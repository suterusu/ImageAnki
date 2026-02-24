// 自動生成
import Foundation

@MainActor
public protocol WordCardRepository: RepositoryBaseFunctionProtocol where Domain == WordCard {
    func fetchByGrade(grade: SchoolGrade, count: StudyItemCount) async throws -> [WordCard]
    func fetchByIDs(ids: [UUID]) async throws -> [WordCard]
}
