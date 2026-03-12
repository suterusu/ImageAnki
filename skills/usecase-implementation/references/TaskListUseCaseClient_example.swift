// Minimal example: one screen -> one UseCase

import Foundation

@MainActor
public protocol TaskListUseCaseProtocol {
    func fetchTasks() async -> AsyncStream<TaskListViewEffect>
    func handleAlertResult(
        _ alertEffect: TaskListAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<TaskListViewEffect>
}

public struct UnimplementedTaskListUseCase: TaskListUseCaseProtocol {
    public nonisolated init() {}

    public func fetchTasks() async -> AsyncStream<TaskListViewEffect> {
        fatalError("fetchTasks is not implemented")
    }

    public func handleAlertResult(
        _ alertEffect: TaskListAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<TaskListViewEffect> {
        fatalError("handleAlertResult is not implemented")
    }
}

@MainActor
public struct TaskListUseCase: TaskListUseCaseProtocol {
    private let taskRepository: any TaskRepository

    public init(taskRepository: any TaskRepository) {
        self.taskRepository = taskRepository
    }

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

    public func handleAlertResult(
        _ alertEffect: TaskListAlertEffect,
        buttonType: ButtonType
    ) async -> AsyncStream<TaskListViewEffect> {
        EffectStream.make { yield in
            switch (alertEffect, buttonType) {
            case (_, .cancel), (.showError, _):
                break
            case (.confirmDelete(let taskID), .confirm):
                // TODO: try await taskRepository.delete(taskID)
                yield(.screen(.showLoading))
                defer { yield(.screen(.hideLoading)) }
            }
        }
    }
}
