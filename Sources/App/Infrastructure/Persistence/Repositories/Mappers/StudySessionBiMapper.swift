import Foundation

public struct StudySessionBiMapper: BiMapper {
    public init() {}

    public func toDomain(_ persistent: StudySessionPersistentModel) throws -> StudySession {
        let decoder = JSONDecoder()
        let dtoAnswers = try decoder.decode([StudyAnswerDTO].self, from: persistent.answersJSON)
        let cardIDs = try decoder.decode([UUID].self, from: persistent.cardIDsJSON)

        let answers: [StudyAnswer] = try dtoAnswers.map { dto in
            switch StudyAnswer.restore(id: dto.id, cardID: dto.cardID, judgment: dto.judgment, answeredAt: dto.answeredAt) {
            case .success(let answer):
                return answer
            case .failure:
                throw MapperError.invalidAnswer
            }
        }

        guard let mode = StudyMode(rawValue: persistent.modeRawValue) else {
            throw MapperError.invalidMode
        }
        let gradeFilter = persistent.gradeFilterRawValue.flatMap(SchoolGrade.init(rawValue:))
        guard let status = StudySessionStatus(rawValue: persistent.statusRawValue) else {
            throw MapperError.invalidStatus
        }

        switch StudySession.restore(
            id: persistent.id,
            startedAt: persistent.startedAt,
            mode: mode,
            gradeFilter: gradeFilter,
            targetCount: persistent.targetCount,
            status: status,
            answers: answers,
            cardIDs: cardIDs
        ) {
        case .success(let session):
            return session
        case .failure:
            throw MapperError.invalidSession
        }
    }

    public func toPersistent(_ domain: StudySession) -> StudySessionPersistentModel {
        let encoder = JSONEncoder()
        let answerDTOs = domain.answers.map {
            StudyAnswerDTO(id: $0.id, cardID: $0.cardID, judgment: $0.judgment, answeredAt: $0.answeredAt)
        }
        let answerData = (try? encoder.encode(answerDTOs)) ?? Data()
        let cardData = (try? encoder.encode(domain.cardIDs)) ?? Data()

        return StudySessionPersistentModel(
            id: domain.id,
            startedAt: domain.startedAt,
            modeRawValue: domain.mode.rawValue,
            gradeFilterRawValue: domain.gradeFilter?.rawValue,
            targetCount: domain.targetCount.value,
            statusRawValue: domain.status.rawValue,
            answersJSON: answerData,
            cardIDsJSON: cardData
        )
    }

    public func update(persistent: StudySessionPersistentModel, from domain: StudySession) {
        let encoder = JSONEncoder()
        let answerDTOs = domain.answers.map {
            StudyAnswerDTO(id: $0.id, cardID: $0.cardID, judgment: $0.judgment, answeredAt: $0.answeredAt)
        }
        persistent.startedAt = domain.startedAt
        persistent.modeRawValue = domain.mode.rawValue
        persistent.gradeFilterRawValue = domain.gradeFilter?.rawValue
        persistent.targetCount = domain.targetCount.value
        persistent.statusRawValue = domain.status.rawValue
        persistent.answersJSON = (try? encoder.encode(answerDTOs)) ?? Data()
        persistent.cardIDsJSON = (try? encoder.encode(domain.cardIDs)) ?? Data()
    }
}

extension StudySessionBiMapper {
    private struct StudyAnswerDTO: Codable {
        let id: UUID
        let cardID: UUID
        let judgment: AnswerJudgment
        let answeredAt: Date
    }

    enum MapperError: Error {
        case invalidMode
        case invalidStatus
        case invalidAnswer
        case invalidSession
    }
}
