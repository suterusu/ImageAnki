import Foundation

public enum ViewEffect<ScreenEffect: Equatable & Sendable, AlertEffect: Equatable & Sendable>: Sendable, Equatable {
    case screen(ScreenEffect)
    case alert(AlertEffect)
}

@MainActor
public protocol AppEffectConvertible: Sendable {
    func asAppEffect() -> AppEffect
}
