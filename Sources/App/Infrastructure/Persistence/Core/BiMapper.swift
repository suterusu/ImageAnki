import Foundation
import SwiftData

public protocol BiMapper {
    associatedtype Domain: Identifiable
    associatedtype Persistent: PersistentModel & Identifiable where Domain.ID == Persistent.ID

    func toDomain(_ persistent: Persistent) throws -> Domain
    func toPersistent(_ domain: Domain) -> Persistent
    func update(persistent: Persistent, from domain: Domain)
}
