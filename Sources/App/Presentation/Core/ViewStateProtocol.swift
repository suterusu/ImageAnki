import Foundation

@MainActor
public protocol ViewStateProtocol {
    associatedtype Effect: Sendable
    func apply(_ effect: Effect)
}
