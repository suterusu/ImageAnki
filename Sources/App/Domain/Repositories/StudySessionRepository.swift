// 自動生成
import Foundation

@MainActor
public protocol StudySessionRepository: RepositoryBaseFunctionProtocol where Domain == StudySession {
    func fetchPerformanceSummaries() async throws -> [PerformanceSummary]
}
