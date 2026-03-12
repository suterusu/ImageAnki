import Foundation

/// タスク一覧画面でのエラー
public enum TaskListError: Error, Sendable {
    // MARK: - Infrastructure由来のエラー（associated valueなし）

    /// タスクの取得に失敗
    case fetchFailed

    /// タスクの更新に失敗
    case updateFailed

    /// タスクの削除に失敗
    case deleteFailed

    // MARK: - ビジネスロジック的な結果（解釈）

    /// タスクが見つからない（Repository層のnilまたはnotFoundを解釈）
    case taskNotFound

    /// 無効なデータ（Repository層のvalidationを解釈）
    case invalidData
}

// MARK: - 使用例

/*
// ScreenEffect / AlertEffect / ViewEffect 定義
public enum TaskListScreenEffect: Equatable, Sendable {
    case showLoading
    case hideLoading
    case showEmptyState
    case refreshList([TaskEntity])
}

public enum TaskListAlertEffect: Equatable, Sendable {
    case showError(TaskListError)  // UseCaseErrorを渡す
}

public typealias TaskListViewEffect = ViewEffect<TaskListScreenEffect, TaskListAlertEffect>

// UseCase実装でViewEffectとして発行
public func fetchTasks() async -> AsyncStream<TaskListViewEffect> {
    EffectStream.make { yield in
        yield(.screen(.showLoading))
        defer { yield(.screen(.hideLoading)) }
        do {
            let tasks = try await taskRepository.fetchAll()
            yield(.screen(tasks.isEmpty ? .showEmptyState : .refreshList(tasks)))
        } catch {
            yield(.alert(.showError(.fetchFailed)))
        }
    }
}

// ViewStateでの処理
@MainActor
@Observable
final class TaskListViewState: AlertViewStateProtocol {
    var isLoading = false
    var alertState: AlertState<TaskListAlertEffect>?

    func apply(_ effect: TaskListViewEffect) {
        switch effect {
        case .screen(.showLoading):
            isLoading = true
        case .screen(.hideLoading):
            isLoading = false
        case .screen:
            break
        case .alert(let alertEffect):
            alertState = makeAlertState(from: alertEffect)
        }
    }

    func makeAlertState(from effect: TaskListAlertEffect) -> AlertState<TaskListAlertEffect> {
        switch effect {
        case .showError(let error):
            return AlertState(
                alertEffect: .showError(error),
                alertType: .informational,
                title: "エラー",
                message: errorMessage(for: error),
                buttonTitle: "OK",
                cancelButtonTitle: nil
            )
        }
    }

    private func errorMessage(for error: TaskListError) -> String {
        switch error {
        case .fetchFailed:
            return "タスクの取得に失敗しました。もう一度お試しください。"
        case .updateFailed:
            return "タスクの更新に失敗しました。もう一度お試しください。"
        case .deleteFailed:
            return "タスクの削除に失敗しました。もう一度お試しください。"
        case .taskNotFound:
            return "タスクが見つかりませんでした。"
        case .invalidData:
            return "データが不正です。"
        }
    }
}
*/
