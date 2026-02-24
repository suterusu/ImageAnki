import Foundation
import ImageAnki

extension WordCard {
    static func test(
        id: UUID = UUID(),
        grade: SchoolGrade = .junior1,
        promptText: String = "apple",
        meaningText: String = "りんご",
        imagePNGName: String = "apple.png"
    ) -> WordCard {
        switch WordCard.restore(
            id: id,
            grade: grade,
            promptText: promptText,
            meaningText: meaningText,
            imagePNGName: imagePNGName
        ) {
        case .success(let card):
            return card
        case .failure:
            fatalError("failed to make test word card")
        }
    }

}

extension StudySession {
    static func test(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        mode: StudyMode = .learning,
        gradeFilter: SchoolGrade? = .junior1,
        targetCount: Int = 1,
        status: StudySessionStatus = .inProgress,
        answers: [StudyAnswer] = [],
        cardIDs: [UUID] = [UUID()]
    ) -> StudySession {
        switch StudySession.restore(
            id: id,
            startedAt: startedAt,
            mode: mode,
            gradeFilter: gradeFilter,
            targetCount: targetCount,
            status: status,
            answers: answers,
            cardIDs: cardIDs
        ) {
        case .success(let session):
            return session
        case .failure:
            fatalError("failed to make test session")
        }
    }
}
