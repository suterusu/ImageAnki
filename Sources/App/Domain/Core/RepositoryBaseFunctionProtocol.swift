// このファイルは自動生成されています

import Foundation

@MainActor
public protocol RepositoryBaseFunctionProtocol {
    associatedtype Domain: Identifiable & Sendable where Domain.ID: Sendable

    func fetchAll() async throws -> [Domain]
    func fetch(id: Domain.ID) async throws -> Domain?
    func insert(_ domain: Domain) async throws
    func update(_ domain: Domain) async throws
    func delete(id: Domain.ID) async throws
}
