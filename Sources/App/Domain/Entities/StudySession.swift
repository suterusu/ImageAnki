// このファイルは自動生成されています

import Foundation

public struct StudySession: Identifiable, Equatable, Sendable {
    public typealias ID = UUID

    public var id: UUID { sessionID }
    public let sessionID: UUID
    public let mode: StudyMode
    public let grade: SchoolGrade?
    public let requestedCount: Int
    public let startedAt: Date
    public private(set) var finishedAt: Date?
    public private(set) var answers: [StudyAnswer]

    private init(
        sessionID: UUID,
        mode: StudyMode,
        grade: SchoolGrade?,
        requestedCount: Int,
        startedAt: Date,
        finishedAt: Date?,
        answers: [StudyAnswer]
    ) {
        self.sessionID = sessionID
        self.mode = mode
        self.grade = grade
        self.requestedCount = requestedCount
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.answers = answers
    }

    public static func make(
        mode: StudyMode,
        grade: SchoolGrade?,
        requestedCount: Int
    ) -> Result<StudySession, StudySessionError> {
        restore(
            id: UUID(),
            mode: mode,
            grade: grade,
            requestedCount: requestedCount,
            startedAt: Date(),
            finishedAt: nil,
            answers: []
        )
    }

    public static func restore(
        id: UUID,
        mode: StudyMode,
        grade: SchoolGrade?,
        requestedCount: Int,
        startedAt: Date,
        finishedAt: Date?,
        answers: [StudyAnswer]
    ) -> Result<StudySession, StudySessionError> {
        guard requestedCount > 0 else { return .failure(.invalidRequestedCount) }
        if mode == .normal && grade == nil {
            return .failure(.gradeRequiredForNormalMode)
        }

        return .success(
            StudySession(
                sessionID: id,
                mode: mode,
                grade: grade,
                requestedCount: requestedCount,
                startedAt: startedAt,
                finishedAt: finishedAt,
                answers: answers
            )
        )
    }

    public mutating func recordAnswer(answer: StudyAnswer) {
        answers.append(answer)
    }

    public mutating func finalize() {
        finishedAt = Date()
    }

    public func summary() -> StudySessionSummary {
        let correctCount = answers.filter { $0.judgment == .correct }.count
        let incorrectCount = answers.filter { $0.judgment == .incorrect }.count
        do {
            return try StudySessionSummary(correctCount: correctCount, incorrectCount: incorrectCount)
        } catch {
            preconditionFailure("StudySessionSummary should always be constructible with non-negative counts")
        }
    }
}

public enum StudySessionError: Error, Equatable, Sendable {
    case invalidRequestedCount
    case gradeRequiredForNormalMode
}
