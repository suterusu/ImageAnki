// このファイルは自動生成されています

import Foundation

public struct WordBiMapper: BiMapper {
    public init() {}

    public func toDomain(_ persistent: WordPersistentModel) throws -> Word {
        guard let grade = SchoolGrade(rawValue: persistent.gradeRawValue) else {
            throw WordBiMapperError.invalidGrade
        }

        switch Word.restore(
            id: persistent.id,
            grade: grade,
            problemImageName: persistent.problemImageName,
            answerImageName: persistent.answerImageName
        ) {
        case .success(let word):
            return word
        case .failure(let error):
            throw error
        }
    }

    public func toPersistent(_ domain: Word) -> WordPersistentModel {
        WordPersistentModel(
            id: domain.id,
            gradeRawValue: domain.grade.rawValue,
            problemImageName: domain.problemImageName,
            answerImageName: domain.answerImageName
        )
    }

    public func update(persistent: WordPersistentModel, from domain: Word) {
        persistent.gradeRawValue = domain.grade.rawValue
        persistent.problemImageName = domain.problemImageName
        persistent.answerImageName = domain.answerImageName
    }
}

public enum WordBiMapperError: Error {
    case invalidGrade
}
