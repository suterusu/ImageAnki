import Foundation
import Observation

@MainActor
protocol ViewStateProtocol: AnyObject, Observable {
    associatedtype ScreenEffect: Equatable & Sendable
    associatedtype AlertEffect: Equatable & Sendable

    func apply(_ effect: ViewEffect<ScreenEffect, AlertEffect>)
}

enum AlertType {
    case informational
    case confirmation
    case destructiveConfirmation
}


struct AlertState<AlertEffect: Equatable & Sendable>: Equatable, Identifiable {
    let id: UUID
    let alertEffect: AlertEffect
    let alertType: AlertType
    let title: String
    let message: String
    let buttonTitle: String
    let cancelButtonTitle: String?

    init(
        alertEffect: AlertEffect,
        alertType: AlertType,
        title: String,
        message: String,
        buttonTitle: String,
        cancelButtonTitle: String?
    ) {
        self.id = UUID()
        self.alertEffect = alertEffect
        self.alertType = alertType
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.cancelButtonTitle = cancelButtonTitle
    }
}

@MainActor
protocol AlertViewStateProtocol: ViewStateProtocol
where ScreenEffect: AppEffectConvertible, AlertEffect: Equatable {

    var alertState: AlertState<AlertEffect>? { get set }
    func makeAlertState(from effect: AlertEffect) -> AlertState<AlertEffect>
}
