import Foundation
@testable import <AppModule>

// 基本的にはBaseRepository_Failing<Element: Identifiable>に適合させる
public typealias VocabularyCardRepository_Failing = BaseRepository_Failing<VocabularyCard>

// 足りない場合は、下のようにextensionで追加する
extension BaseRepository_Failing: VocabularyCardRepository where Element == VocabularyCard {
    public func fetchByCustomQuery() async throws -> [VocabularyCard] {
        throw RepositoryFailingError.forcedFailure
    }
}

// 以下は共通ファイルとして運用
public enum RepositoryFailingError: Error, Sendable {
    case forcedFailure
}

public struct BaseRepository_Failing<Element: Identifiable>: RepositoryBaseFunctionProtocol {
    public typealias Domain = Element
    public typealias ID = Element.ID

    public func fetchAll() async throws -> [Element] {
        throw RepositoryFailingError.forcedFailure
    }

    public func fetch(id: ID) async throws -> Element? {
        throw RepositoryFailingError.forcedFailure
    }

    public func insert(_ domain: Element) async throws {
        throw RepositoryFailingError.forcedFailure
    }

    public func update(_ domain: Element) async throws {
        throw RepositoryFailingError.forcedFailure
    }

    public func delete(id: ID) async throws {
        throw RepositoryFailingError.forcedFailure
    }
}
