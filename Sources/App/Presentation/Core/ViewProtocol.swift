// このファイルは自動生成されています

import SwiftUI

@MainActor
public protocol ViewStateProtocol: AnyObject {
    associatedtype Effect: AppEffectConvertible
    func apply(_ effect: Effect)
}

@MainActor
public protocol EffectHandlingView {
    associatedtype ViewState: ViewStateProtocol
    var viewState: ViewState { get }
    var appState: AppState { get }
}

extension EffectHandlingView {
    @MainActor
    public func handle(
        _ makeStream: @Sendable @escaping () async -> AsyncStream<ViewState.Effect>
    ) {
        Task {
            let stream = await makeStream()
            for await effect in stream {
                viewState.apply(effect)
                appState.apply(effect.asAppEffect())
            }
        }
    }
}
