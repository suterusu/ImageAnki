// このファイルは自動生成されています

import Foundation
import Observation

public struct ProblemListRow: Equatable, Sendable, Identifiable {
    public let sessionID: UUID
    public let title: String
    public let summary: String

    public var id: UUID { sessionID }

    public init(sessionID: UUID, title: String, summary: String) {
        self.sessionID = sessionID
        self.title = title
        self.summary = summary
    }
}

@MainActor
@Observable
public final class ProblemListScreenViewState: ViewStateProtocol {
    public typealias Effect = ProblemListScreenViewEffect

    public var rows: [ProblemListRow] = []
    public var selectedSessionID: UUID?
    public var isLoading: Bool = false
    public var isEmptyStateVisible: Bool = false
    public var alertMessage: String?

    public init() {}

    public func apply(_ effect: ProblemListScreenViewEffect) {
        switch effect {
        case .showLoading:
            isLoading = true
        case .hideLoading:
            isLoading = false
        case .showError(let error):
            alertMessage = errorMessage(for: error)
        case .showEmptyState:
            rows = []
            isEmptyStateVisible = true
        case .showHistoryList(let sessions):
            isEmptyStateVisible = sessions.isEmpty
            rows = sessions.enumerated().map { offset, session in
                let summary = session.summary()
                return ProblemListRow(
                    sessionID: session.id,
                    title: "第\(offset + 1)回",
                    summary: "正解 \(summary.correctCount) / 不正解 \(summary.incorrectCount)"
                )
            }
        case .navigateToStudyResult(let sessionID):
            selectedSessionID = sessionID
        }
    }

    private func errorMessage(for error: ProblemListScreenError) -> String {
        switch error {
        case .loadFailed:
            return "履歴の読み込みに失敗しました。"
        }
    }
}
