import Foundation

public struct WordCardBiMapper: BiMapper {
    public init() {}

    public func toDomain(_ persistent: WordCardPersistentModel) throws -> WordCard {
        guard let grade = SchoolGrade(rawValue: persistent.gradeRawValue) else {
            throw MapperError.invalidGrade
        }

        switch WordCard.restore(
            id: persistent.id,
            grade: grade,
            promptText: persistent.promptText,
            meaningText: persistent.meaningText,
            imagePNGName: persistent.imagePNGName
        ) {
        case .success(let domain):
            return domain
        case .failure:
            throw MapperError.invalidWordCard
        }
    }

    public func toPersistent(_ domain: WordCard) -> WordCardPersistentModel {
        WordCardPersistentModel(
            id: domain.id,
            gradeRawValue: domain.grade.rawValue,
            promptText: domain.promptText.value,
            meaningText: domain.meaningText.value,
            imagePNGName: domain.imagePNGName.value
        )
    }

    public func update(persistent: WordCardPersistentModel, from domain: WordCard) {
        persistent.gradeRawValue = domain.grade.rawValue
        persistent.promptText = domain.promptText.value
        persistent.meaningText = domain.meaningText.value
        persistent.imagePNGName = domain.imagePNGName.value
    }
}

extension WordCardBiMapper {
    enum MapperError: Error {
        case invalidGrade
        case invalidWordCard
    }
}
