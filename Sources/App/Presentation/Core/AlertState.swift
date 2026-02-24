import Foundation

public enum ButtonType: Sendable {
    case confirm
    case cancel
}

public enum AlertType: Sendable {
    case informational
    case destructiveConfirmation
    case normalConfirmation
}

public struct AlertState<AlertEffect: Sendable>: Identifiable, Sendable {
    public let id = UUID()
    public let alertEffect: AlertEffect
    public let alertType: AlertType
    public let title: String
    public let message: String
    public let buttonTitle: String
    public let cancelButtonTitle: String?

    public init(
        alertEffect: AlertEffect,
        alertType: AlertType,
        title: String,
        message: String,
        buttonTitle: String,
        cancelButtonTitle: String?
    ) {
        self.alertEffect = alertEffect
        self.alertType = alertType
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.cancelButtonTitle = cancelButtonTitle
    }
}
