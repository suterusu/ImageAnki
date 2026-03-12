// AppState 実装例
// 参考コード

import SwiftUI
import Observation

public enum AppTab: Hashable {
    case taskList
    case settings
}

// MARK: - AppState

@MainActor
@Observable
public final class AppState {
    public var selectedTab: AppTab = .taskList // 例: アプリの初期タブに置き換える
    public var navigationPath = NavigationPath()

    public init() {}

    // MARK: - ScreenEffect処理

    public func apply(_ effect: AppEffect) {
        switch effect {
        case .taskList(let effect):
            switch effect {
            case .navigateToCreateTask:
                navigationPath.append(Screen.createTask)
            case .navigateToEditTask(let taskID):
                navigationPath.append(Screen.editTask(id: taskID))
            default:
                break // UI系はViewStateが処理
            }
        case .create(let effect):
            switch effect {
            case .navigateToList:
                if !navigationPath.isEmpty {
                    navigationPath.removeLast()
                }
            default:
                break
            }
        case .edit(let effect):
            switch effect {
            case .navigateToList:
                if !navigationPath.isEmpty {
                    navigationPath.removeLast()
                }
            default:
                break
            }
        }
    }
}

// MARK: - ポイント

// 1. apply メソッドで全てのScreenEffect画面遷移を処理
// 2. case .taskList(let effect): でScreenEffectの画面遷移を処理
// 3. default: break で画面遷移以外（UI系）はスキップ
// 4. navigationPath.append で画面追加
// 5. navigationPath.removeLast で画面を閉じる（空チェック必須）
// 6. selectedTab でTabViewの選択状態を保持する
// 7. AppStateからUseCaseは呼ばない（UseCase実行はRootView/View側）
