// 自動生成
import Foundation

public enum ViewEffect<ScreenEffect: Sendable, AlertEffect: Sendable>: Sendable {
    case screen(ScreenEffect)
    case alert(AlertEffect)
}

extension ViewEffect: Equatable where ScreenEffect: Equatable, AlertEffect: Equatable {}
