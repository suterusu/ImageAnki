import Foundation
import SwiftData

@Model
public final class WordCardPersistentModel: Identifiable {
    public var id: UUID
    public var gradeRawValue: String
    public var promptText: String
    public var meaningText: String
    public var imagePNGName: String

    public init(id: UUID, gradeRawValue: String, promptText: String, meaningText: String, imagePNGName: String) {
        self.id = id
        self.gradeRawValue = gradeRawValue
        self.promptText = promptText
        self.meaningText = meaningText
        self.imagePNGName = imagePNGName
    }
}
