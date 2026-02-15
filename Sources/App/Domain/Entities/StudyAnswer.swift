// このファイルは自動生成されています

import Foundation

public struct StudyAnswer: Identifiable, Equatable, Sendable {
    public typealias ID = UUID

    public var id: UUID { answerID }
    public let answerID: UUID
    public let wordID: UUID
    public let judgment: AnswerJudgment
    public let answeredAt: Date

    private init(
        answerID: UUID,
        wordID: UUID,
        judgment: AnswerJudgment,
        answeredAt: Date
    ) {
        self.answerID = answerID
        self.wordID = wordID
        self.judgment = judgment
        self.answeredAt = answeredAt
    }

    public static func make(wordID: UUID, judgment: AnswerJudgment) -> Result<StudyAnswer, StudyAnswerError> {
        .success(
            StudyAnswer(
                answerID: UUID(),
                wordID: wordID,
                judgment: judgment,
                answeredAt: Date()
            )
        )
    }

    public static func restore(
        id: UUID,
        wordID: UUID,
        judgment: AnswerJudgment,
        answeredAt: Date
    ) -> Result<StudyAnswer, StudyAnswerError> {
        .success(
            StudyAnswer(
                answerID: id,
                wordID: wordID,
                judgment: judgment,
                answeredAt: answeredAt
            )
        )
    }
}

public enum StudyAnswerError: Error, Equatable, Sendable {
    case invalidWordID
}
