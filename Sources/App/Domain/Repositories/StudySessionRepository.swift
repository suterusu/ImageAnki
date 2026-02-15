// このファイルは自動生成されています

import Foundation

public protocol StudySessionRepository: RepositoryBaseFunctionProtocol, Sendable where Domain == StudySession {
    func save(session: StudySession) async throws
}
