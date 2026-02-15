// このファイルは自動生成されています

import Foundation

public struct StudySessionBiMapper: BiMapper {
    public init() {}

    public func toDomain(_ persistent: StudySessionPersistentModel) throws -> StudySession {
        guard let mode = StudyMode(rawValue: persistent.modeRawValue) else {
            throw StudySessionBiMapperError.invalidMode
        }

        let grade: SchoolGrade?
        if let gradeRawValue = persistent.gradeRawValue {
            guard let resolvedGrade = SchoolGrade(rawValue: gradeRawValue) else {
                throw StudySessionBiMapperError.invalidGrade
            }
            grade = resolvedGrade
        } else {
            grade = nil
        }

        let answers: [StudyAnswer] = try persistent.answers.map { answerPersistent in
            guard let judgment = AnswerJudgment(rawValue: answerPersistent.judgmentRawValue) else {
                throw StudySessionBiMapperError.invalidJudgment
            }
            switch StudyAnswer.restore(
                id: answerPersistent.id,
                wordID: answerPersistent.wordID,
                judgment: judgment,
                answeredAt: answerPersistent.answeredAt
            ) {
            case .success(let answer):
                return answer
            case .failure(let error):
                throw error
            }
        }

        switch StudySession.restore(
            id: persistent.id,
            mode: mode,
            grade: grade,
            requestedCount: persistent.requestedCount,
            startedAt: persistent.startedAt,
            finishedAt: persistent.finishedAt,
            answers: answers
        ) {
        case .success(let session):
            return session
        case .failure(let error):
            throw error
        }
    }

    public func toPersistent(_ domain: StudySession) -> StudySessionPersistentModel {
        StudySessionPersistentModel(
            id: domain.id,
            modeRawValue: domain.mode.rawValue,
            gradeRawValue: domain.grade?.rawValue,
            requestedCount: domain.requestedCount,
            startedAt: domain.startedAt,
            finishedAt: domain.finishedAt,
            answers: domain.answers.map {
                StudyAnswerPersistentModel(
                    id: $0.id,
                    wordID: $0.wordID,
                    judgmentRawValue: $0.judgment.rawValue,
                    answeredAt: $0.answeredAt
                )
            }
        )
    }

    public func update(persistent: StudySessionPersistentModel, from domain: StudySession) {
        persistent.modeRawValue = domain.mode.rawValue
        persistent.gradeRawValue = domain.grade?.rawValue
        persistent.requestedCount = domain.requestedCount
        persistent.startedAt = domain.startedAt
        persistent.finishedAt = domain.finishedAt
        persistent.answers = domain.answers.map {
            StudyAnswerPersistentModel(
                id: $0.id,
                wordID: $0.wordID,
                judgmentRawValue: $0.judgment.rawValue,
                answeredAt: $0.answeredAt
            )
        }
    }
}

public enum StudySessionBiMapperError: Error {
    case invalidMode
    case invalidGrade
    case invalidJudgment
}
