// このファイルは自動生成されています

import Foundation

public struct Word: Identifiable, Equatable, Sendable {
    public typealias ID = UUID

    public var id: UUID { wordID }
    public let wordID: UUID
    public let grade: SchoolGrade
    public let problemImageName: String
    public let answerImageName: String

    private init(
        wordID: UUID,
        grade: SchoolGrade,
        problemImageName: String,
        answerImageName: String
    ) {
        self.wordID = wordID
        self.grade = grade
        self.problemImageName = problemImageName
        self.answerImageName = answerImageName
    }

    public static func make(
        grade: SchoolGrade,
        problemImageName: String,
        answerImageName: String
    ) -> Result<Word, WordError> {
        restore(
            id: UUID(),
            grade: grade,
            problemImageName: problemImageName,
            answerImageName: answerImageName
        )
    }

    public static func restore(
        id: UUID,
        grade: SchoolGrade,
        problemImageName: String,
        answerImageName: String
    ) -> Result<Word, WordError> {
        guard !problemImageName.isEmpty else { return .failure(.emptyProblemImageName) }
        guard !answerImageName.isEmpty else { return .failure(.emptyAnswerImageName) }

        return .success(
            Word(
                wordID: id,
                grade: grade,
                problemImageName: problemImageName,
                answerImageName: answerImageName
            )
        )
    }
}

public enum WordError: Error, Equatable, Sendable {
    case emptyProblemImageName
    case emptyAnswerImageName
}
