import Foundation
@testable import <AppModule>

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
