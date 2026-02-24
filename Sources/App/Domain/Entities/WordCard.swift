// 自動生成
import Foundation

public struct WordCard: Identifiable, Equatable, Sendable {
    public typealias ID = UUID

    public var id: UUID { wordCardID }
    public let wordCardID: UUID
    public let grade: SchoolGrade
    public let promptText: PromptText
    public let meaningText: MeaningText
    public let imagePNGName: ImagePNGName

    private init(
        id: UUID,
        grade: SchoolGrade,
        promptText: PromptText,
        meaningText: MeaningText,
        imagePNGName: ImagePNGName
    ) {
        self.wordCardID = id
        self.grade = grade
        self.promptText = promptText
        self.meaningText = meaningText
        self.imagePNGName = imagePNGName
    }

    public static func make(
        grade: SchoolGrade,
        promptText: String,
        meaningText: String,
        imagePNGName: String
    ) -> Result<WordCard, WordCardError> {
        create(id: UUID(), grade: grade, promptText: promptText, meaningText: meaningText, imagePNGName: imagePNGName)
    }

    public static func restore(
        id: UUID,
        grade: SchoolGrade,
        promptText: String,
        meaningText: String,
        imagePNGName: String
    ) -> Result<WordCard, WordCardError> {
        create(id: id, grade: grade, promptText: promptText, meaningText: meaningText, imagePNGName: imagePNGName)
    }

    private static func create(
        id: UUID,
        grade: SchoolGrade,
        promptText: String,
        meaningText: String,
        imagePNGName: String
    ) -> Result<WordCard, WordCardError> {
        do {
            let prompt = try PromptText(promptText)
            let meaning = try MeaningText(meaningText)
            let imageName = try ImagePNGName(imagePNGName)
            return .success(
                WordCard(
                    id: id,
                    grade: grade,
                    promptText: prompt,
                    meaningText: meaning,
                    imagePNGName: imageName
                )
            )
        } catch let error as PromptTextError {
            return .failure(.promptText(error))
        } catch let error as MeaningTextError {
            return .failure(.meaningText(error))
        } catch let error as ImagePNGNameError {
            return .failure(.imagePNGName(error))
        } catch {
            return .failure(.unknown)
        }
    }
}

public enum WordCardError: Error, Equatable, Sendable {
    case promptText(PromptTextError)
    case meaningText(MeaningTextError)
    case imagePNGName(ImagePNGNameError)
    case unknown
}
