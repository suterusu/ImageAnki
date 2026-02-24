// 自動生成
import Foundation

public struct StudySession: Identifiable, Equatable, Sendable {
    public typealias ID = UUID

    public var id: UUID { studySessionID }
    public let studySessionID: UUID
    public let startedAt: Date
    public let mode: StudyMode
    public let gradeFilter: SchoolGrade?
    public let targetCount: StudyItemCount
    public private(set) var status: StudySessionStatus
    public private(set) var answers: [StudyAnswer]
    public let cardIDs: [UUID]

    private init(
        id: UUID,
        startedAt: Date,
        mode: StudyMode,
        gradeFilter: SchoolGrade?,
        targetCount: StudyItemCount,
        status: StudySessionStatus,
        answers: [StudyAnswer],
        cardIDs: [UUID]
    ) {
        self.studySessionID = id
        self.startedAt = startedAt
        self.mode = mode
        self.gradeFilter = gradeFilter
        self.targetCount = targetCount
        self.status = status
        self.answers = answers
        self.cardIDs = cardIDs
    }

    public static func make(
        startedAt: Date,
        mode: StudyMode,
        gradeFilter: SchoolGrade?,
        targetCount: Int,
        cardIDs: [UUID]
    ) -> Result<StudySession, StudySessionError> {
        create(
            id: UUID(),
            startedAt: startedAt,
            mode: mode,
            gradeFilter: gradeFilter,
            targetCount: targetCount,
            status: .inProgress,
            answers: [],
            cardIDs: cardIDs
        )
    }

    public static func restore(
        id: UUID,
        startedAt: Date,
        mode: StudyMode,
        gradeFilter: SchoolGrade?,
        targetCount: Int,
        status: StudySessionStatus,
        answers: [StudyAnswer],
        cardIDs: [UUID]
    ) -> Result<StudySession, StudySessionError> {
        create(
            id: id,
            startedAt: startedAt,
            mode: mode,
            gradeFilter: gradeFilter,
            targetCount: targetCount,
            status: status,
            answers: answers,
            cardIDs: cardIDs
        )
    }

    private static func create(
        id: UUID,
        startedAt: Date,
        mode: StudyMode,
        gradeFilter: SchoolGrade?,
        targetCount: Int,
        status: StudySessionStatus,
        answers: [StudyAnswer],
        cardIDs: [UUID]
    ) -> Result<StudySession, StudySessionError> {
        do {
            let count = try StudyItemCount(targetCount)
            guard !cardIDs.isEmpty else { return .failure(.cardListIsEmpty) }
            return .success(
                StudySession(
                    id: id,
                    startedAt: startedAt,
                    mode: mode,
                    gradeFilter: gradeFilter,
                    targetCount: count,
                    status: status,
                    answers: answers,
                    cardIDs: cardIDs
                )
            )
        } catch let error as StudyItemCountError {
            return .failure(.targetCount(error))
        } catch {
            return .failure(.unknown)
        }
    }

    public var answeredCount: Int {
        answers.count
    }

    public var isFinished: Bool {
        answers.count >= targetCount.value
    }

    public var currentCardID: UUID? {
        guard answers.count < cardIDs.count else { return nil }
        return cardIDs[answers.count]
    }

    public mutating func recordAnswer(cardID: UUID, judgment: AnswerJudgment, answeredAt: Date) -> Result<Void, StudySessionError> {
        guard status == .inProgress else { return .failure(.alreadyCompleted) }
        guard answers.count < targetCount.value else { return .failure(.alreadyCompleted) }
        switch StudyAnswer.make(cardID: cardID, judgment: judgment, answeredAt: answeredAt) {
        case .success(let answer):
            answers.append(answer)
            _ = completeIfFinished()
            return .success(())
        case .failure:
            return .failure(.unknown)
        }
    }

    @discardableResult
    public mutating func completeIfFinished() -> Bool {
        if answers.count >= targetCount.value {
            status = .completed
            return true
        }
        return false
    }

    public func correctCount() -> Int {
        answers.filter { $0.judgment == .correct }.count
    }

    public func incorrectCount() -> Int {
        answers.filter { $0.judgment == .incorrect }.count
    }
}

public enum StudySessionError: Error, Equatable, Sendable {
    case targetCount(StudyItemCountError)
    case cardListIsEmpty
    case alreadyCompleted
    case unknown
}
