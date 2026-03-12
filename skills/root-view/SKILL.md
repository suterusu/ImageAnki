---
name: root-view
description: |
  AppStateを所有するRootViewを実装し、NavigationStackと画面遷移を構成するときに使う。
---

# Root View

## 概要

このタスクで何を行うか:
- `Sources/App/Presentation/RootView.swift` を実装し、アプリの遷移起点を構成する。
- `AppState` をRootViewで所有し、`NavigationStack`・`TabView`・`navigationDestination` で遷移を管理する。

入力:

- `Sources/App/Presentation/AppState.swift`（または同等の定義）
- `Sources/App/Presentation/Views/*`（遷移先View）

参照（テンプレート・ガイドライン）:

- `skills/app-state-implementation/SKILL.md` — AppState設計の参考

出力:

- `Sources/App/Presentation/RootView.swift`

## ワークフロー

1. 遷移要素を確認する
   - 入力: `AppState`、`Screen`、`AppTab`、遷移先View定義
   - 実施内容: ルート画面、push遷移先、タブ項目を確認し、`RootView` が扱う要素を決定する。
   - 実施ルール:
     - `Screen` のケース名と遷移先View名の対応を崩さない
     - RootViewは状態所有と遷移構築に責務を限定する
   - 実装パターン: この手順は確認フェーズのため、コード追加は行わず対応表のみ整理する

2. RootViewの骨格を実装する
   - 入力: 手順1の対応表、既存 `RootView.swift`
   - 実施内容: `@State private var appState = AppState()` を持つ `RootView` を実装し、`NavigationStack(path: $appState.navigationPath)` を最外に配置する。`TabView(selection: $appState.selectedTab)` を必ず配置し、`navigationDestination` の `switch` に遷移先を定義する。
   - 実施ルール:
     - RootViewは `AppState` を `@State` で所有する
     - `NavigationStack` はRootViewで1つだけ使い、ネストしない
     - `.environment(appState)` を必ず付与する
     - タブ選択は通常のBinding（`$appState.selectedTab`）を使う
   - 実装パターン:

     ```swift
     struct RootView: View {
         @State private var appState = AppState()

         var body: some View {
             NavigationStack(path: $appState.navigationPath) {
                 TabView(selection: $appState.selectedTab) {
                     TaskListView()
                         .tabItem { Label("一覧", systemImage: "list.bullet") }
                         .tag(AppTab.taskList)
                     SettingsView()
                         .tabItem { Label("設定", systemImage: "gearshape") }
                         .tag(AppTab.settings)
                 }
                 .navigationDestination(for: Screen.self) { destination in
                     switch destination {
                     case .createTask: CreateTaskView()
                     }
                 }
             }
             .environment(appState)
         }
     }
     ```

3. 変更影響を検証する
   - 入力: 更新後 `RootView.swift`、`AppState`、遷移先View
   - 実施内容: 遷移不能ケース、未接続ケース、重複ナビゲーションの有無を確認する。
   - 実施ルール:
     - `navigationDestination` の `switch` で必要ケースを漏らさない
     - RootView以外で `AppState` を再生成しない
     - `NavigationStack` のネストを発生させない
   - 実装パターン: この手順は確認フェーズのため、差分と遷移確認観点のみ記録する

## チェックリスト

- `RootView` が `@State private var appState = AppState()` を保持している
- `NavigationStack(path: $appState.navigationPath)` がRootで1つだけ定義されている
- `.environment(appState)` が設定され、子Viewへ注入されている
- `navigationDestination(for: Screen.self)` の遷移先が `Screen` 定義と一致している
- `TabView(selection: $appState.selectedTab)` を使用している
