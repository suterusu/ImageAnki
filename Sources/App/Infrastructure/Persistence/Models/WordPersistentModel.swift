// このファイルは自動生成されています

import Foundation
import SwiftData

@Model
public final class WordPersistentModel: Identifiable {
    public var id: UUID
    public var gradeRawValue: String
    public var problemImageName: String
    public var answerImageName: String

    public init(
        id: UUID,
        gradeRawValue: String,
        problemImageName: String,
        answerImageName: String
    ) {
        self.id = id
        self.gradeRawValue = gradeRawValue
        self.problemImageName = problemImageName
        self.answerImageName = answerImageName
    }
}
