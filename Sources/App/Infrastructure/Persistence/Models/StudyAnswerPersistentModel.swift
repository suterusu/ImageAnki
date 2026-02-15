// このファイルは自動生成されています

import Foundation
import SwiftData

@Model
public final class StudyAnswerPersistentModel: Identifiable {
    public var id: UUID
    public var wordID: UUID
    public var judgmentRawValue: String
    public var answeredAt: Date

    public init(id: UUID, wordID: UUID, judgmentRawValue: String, answeredAt: Date) {
        self.id = id
        self.wordID = wordID
        self.judgmentRawValue = judgmentRawValue
        self.answeredAt = answeredAt
    }
}
