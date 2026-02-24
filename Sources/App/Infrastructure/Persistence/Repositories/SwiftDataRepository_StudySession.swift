import Foundation

public typealias SwiftDataRepository_StudySession = SwiftDataRepository<StudySessionBiMapper>

extension SwiftDataRepository: StudySessionRepository where Mapper == StudySessionBiMapper {
    public func fetchPerformanceSummaries() async throws -> [PerformanceSummary] {
        let sessions = try await fetchAll()
        return try sessions
            .sorted { $0.startedAt > $1.startedAt }
            .map { session in
                try PerformanceSummary(
                    sessionID: session.id,
                    studiedAt: session.startedAt,
                    gradeLabel: session.gradeFilter?.rawValue ?? "全学年",
                    correctCount: session.correctCount(),
                    incorrectCount: session.incorrectCount()
                )
            }
    }
}
