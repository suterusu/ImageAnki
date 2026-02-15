// このファイルは自動生成されています

import Foundation
import SwiftData

@Model
public final class StudySessionPersistentModel: Identifiable {
    public var id: UUID
    public var modeRawValue: String
    public var gradeRawValue: String?
    public var requestedCount: Int
    public var startedAt: Date
    public var finishedAt: Date?

    @Relationship(deleteRule: .cascade)
    public var answers: [StudyAnswerPersistentModel]

    public init(
        id: UUID,
        modeRawValue: String,
        gradeRawValue: String?,
        requestedCount: Int,
        startedAt: Date,
        finishedAt: Date?,
        answers: [StudyAnswerPersistentModel]
    ) {
        self.id = id
        self.modeRawValue = modeRawValue
        self.gradeRawValue = gradeRawValue
        self.requestedCount = requestedCount
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.answers = answers
    }
}
