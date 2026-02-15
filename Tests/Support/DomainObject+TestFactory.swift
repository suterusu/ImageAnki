import Foundation
@testable import App

enum TestFactory {
    static func word(
        id: UUID = UUID(),
        grade: SchoolGrade = .middle1,
        problemImageName: String = "problem.png",
        answerImageName: String = "answer.png"
    ) throws -> Word {
        switch Word.restore(
            id: id,
            grade: grade,
            problemImageName: problemImageName,
            answerImageName: answerImageName
        ) {
        case .success(let word):
            return word
        case .failure(let error):
            throw error
        }
    }

    static func session(
        id: UUID = UUID(),
        mode: StudyMode = .normal,
        grade: SchoolGrade? = .middle1,
        requestedCount: Int = 1,
        answers: [StudyAnswer] = []
    ) throws -> StudySession {
        switch StudySession.restore(
            id: id,
            mode: mode,
            grade: grade,
            requestedCount: requestedCount,
            startedAt: Date(),
            finishedAt: nil,
            answers: answers
        ) {
        case .success(let session):
            return session
        case .failure(let error):
            throw error
        }
    }

    static func answer(
        id: UUID = UUID(),
        wordID: UUID,
        judgment: AnswerJudgment = .correct
    ) throws -> StudyAnswer {
        switch StudyAnswer.restore(
            id: id,
            wordID: wordID,
            judgment: judgment,
            answeredAt: Date()
        ) {
        case .success(let answer):
            return answer
        case .failure(let error):
            throw error
        }
    }
}
