import SwiftUI

public protocol EffectHandlingView: View {}

extension View {
    @MainActor
    public func bindAlert<AlertEffect: Sendable>(
        alertState: Binding<AlertState<AlertEffect>?>,
        onResult: @escaping (AlertEffect, ButtonType) -> Void
    ) -> some View {
        alert(item: alertState) { state in
            switch state.alertType {
            case .informational:
                return Alert(
                    title: Text(state.title),
                    message: Text(state.message),
                    dismissButton: .default(Text(state.buttonTitle)) {
                        onResult(state.alertEffect, .confirm)
                    }
                )
            case .destructiveConfirmation:
                return Alert(
                    title: Text(state.title),
                    message: Text(state.message),
                    primaryButton: .destructive(Text(state.buttonTitle)) {
                        onResult(state.alertEffect, .confirm)
                    },
                    secondaryButton: .cancel(Text(state.cancelButtonTitle ?? "キャンセル")) {
                        onResult(state.alertEffect, .cancel)
                    }
                )
            case .normalConfirmation:
                return Alert(
                    title: Text(state.title),
                    message: Text(state.message),
                    primaryButton: .default(Text(state.buttonTitle)) {
                        onResult(state.alertEffect, .confirm)
                    },
                    secondaryButton: .cancel(Text(state.cancelButtonTitle ?? "キャンセル")) {
                        onResult(state.alertEffect, .cancel)
                    }
                )
            }
        }
    }
}
