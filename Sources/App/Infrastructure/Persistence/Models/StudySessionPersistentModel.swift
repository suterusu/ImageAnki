import Foundation
import SwiftData

@Model
public final class StudySessionPersistentModel: Identifiable {
    public var id: UUID
    public var startedAt: Date
    public var modeRawValue: String
    public var gradeFilterRawValue: String?
    public var targetCount: Int
    public var statusRawValue: String
    public var answersJSON: Data
    public var cardIDsJSON: Data

    public init(
        id: UUID,
        startedAt: Date,
        modeRawValue: String,
        gradeFilterRawValue: String?,
        targetCount: Int,
        statusRawValue: String,
        answersJSON: Data,
        cardIDsJSON: Data
    ) {
        self.id = id
        self.startedAt = startedAt
        self.modeRawValue = modeRawValue
        self.gradeFilterRawValue = gradeFilterRawValue
        self.targetCount = targetCount
        self.statusRawValue = statusRawValue
        self.answersJSON = answersJSON
        self.cardIDsJSON = cardIDsJSON
    }
}
