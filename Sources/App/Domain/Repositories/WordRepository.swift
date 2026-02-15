// このファイルは自動生成されています

import Foundation

public protocol WordRepository: RepositoryBaseFunctionProtocol, Sendable where Domain == Word {
    func fetchByGrade(grade: SchoolGrade, limit: Int) async throws -> [Word]
    func fetchByIDs(ids: [UUID]) async throws -> [Word]
}
