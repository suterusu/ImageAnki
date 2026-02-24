// 自動生成
import Foundation

public struct StudyAnswer: Identifiable, Equatable, Sendable {
    public typealias ID = UUID

    public var id: UUID { studyAnswerID }
    public let studyAnswerID: UUID
    public let cardID: UUID
    public let judgment: AnswerJudgment
    public let answeredAt: Date

    private init(id: UUID, cardID: UUID, judgment: AnswerJudgment, answeredAt: Date) {
        self.studyAnswerID = id
        self.cardID = cardID
        self.judgment = judgment
        self.answeredAt = answeredAt
    }

    public static func make(cardID: UUID, judgment: AnswerJudgment, answeredAt: Date) -> Result<StudyAnswer, StudyAnswerError> {
        .success(StudyAnswer(id: UUID(), cardID: cardID, judgment: judgment, answeredAt: answeredAt))
    }

    public static func restore(id: UUID, cardID: UUID, judgment: AnswerJudgment, answeredAt: Date) -> Result<StudyAnswer, StudyAnswerError> {
        .success(StudyAnswer(id: id, cardID: cardID, judgment: judgment, answeredAt: answeredAt))
    }
}

public enum StudyAnswerError: Error, Equatable, Sendable {}
