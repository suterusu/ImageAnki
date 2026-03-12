import Foundation
import SwiftUI

@MainActor
protocol EffectHandlingView: View {
    associatedtype ScreenViewState: ViewStateProtocol

    var viewState: ScreenViewState { get set }
    var appState: AppState { get }
}

extension EffectHandlingView where ScreenViewState: AlertViewStateProtocol {
    @MainActor
    func handle(
        _ makeStream:
            @MainActor @escaping () async -> AsyncStream<
                ViewEffect<ScreenViewState.ScreenEffect, ScreenViewState.AlertEffect>
            >
    ) {
        Task {
            let effectStream = await makeStream()
            for await effect in effectStream {
                viewState.apply(effect)
                if case .screen(let screenEffect) = effect {
                    appState.apply(screenEffect.asAppEffect())
                }
            }
        }
    }
}

extension View {
    @MainActor
    func bindAlert<AlertEffect>(
        alertState: Binding<AlertState<AlertEffect>?>,
        tapButton: @escaping @MainActor (AlertEffect, ButtonType) -> Void
    ) -> some View {
        modifier(BindAlertModifier(alertState: alertState, tapButton: tapButton))
    }
}

private struct BindAlertModifier<Effect: Sendable & Equatable>: ViewModifier {
    @Binding var alertState: AlertState<Effect>?
    let tapButton: @MainActor (Effect, ButtonType) -> Void

    func body(content: Content) -> some View {
        content.alert(item: $alertState) { alertState in
            switch alertState.alertType {
            case .informational:
                return Alert(
                    title: Text(alertState.title),
                    message: Text(alertState.message),
                    dismissButton: .default(Text(alertState.buttonTitle)) {
                        tapButton(alertState.alertEffect, .confirm)
                    }
                )

            case .confirmation:
                return Alert(
                    title: Text(alertState.title),
                    message: Text(alertState.message),
                    primaryButton: .default(Text(alertState.buttonTitle)) {
                        tapButton(alertState.alertEffect, .confirm)
                    },
                    secondaryButton: .cancel(Text(alertState.cancelButtonTitle ?? "キャンセル")) {
                        tapButton(alertState.alertEffect, .cancel)
                    }
                )

            case .destructiveConfirmation:
                return Alert(
                    title: Text(alertState.title),
                    message: Text(alertState.message),
                    primaryButton: .destructive(Text(alertState.buttonTitle)) {
                        tapButton(alertState.alertEffect, .confirm)
                    },
                    secondaryButton: .cancel(Text(alertState.cancelButtonTitle ?? "キャンセル")) {
                        tapButton(alertState.alertEffect, .cancel)
                    }
                )
            }
        }
    }
}
