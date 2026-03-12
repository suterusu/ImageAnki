import Foundation
@testable import <AppModule>

extension VocabularyCard {
    static func makeForTest(
        id: Int8 = 1,
        term: String = "term",
        meaning: String = "meaning"
    ) throws -> VocabularyCard {
        try VocabularyCard(
            id: .test(id),
            term: VocabularyTerm(term),
            meaning: VocabularyMeaning(meaning)
        )
    }
}

private extension UUID {
    static func test(_ id: Int8) -> UUID {
        UUID(
            uuid: (
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, UInt8(bitPattern: id)
            )
        )
    }
}
