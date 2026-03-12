---
name: swiftui-view-implementation
description: |
  ユースケース記述と画面設計情報から、画面単位のSwiftUI Viewを実装するときに使う。
---

# SwiftUI View Implementation

## 概要

このタスクで何を行うか:

- `docs/usecases/<ScreenName>/<ScreenName>.md` を仕様として、`Sources/App/Presentation/Views/<ScreenName>View.swift` を実装する。
- Viewの責務に限定し、業務処理はUseCase、状態更新はViewState、遷移はAppStateへ委譲する。

入力:

- 必須: `docs/usecases/<ScreenName>/<ScreenName>.md`
- 必須（存在する場合）: `docs/usecases/<ScreenName>/<ScreenName>.pen`
- 任意: `docs/usecases/<ScreenName>/viewScript.md`

参照（テンプレート・ガイドライン）:

- `skills/_shared/RESPONSIBILITY_BOUNDARIES.md` — 責務境界の判断基準

出力:

- `Sources/App/Presentation/Views/<ScreenName>View.swift`
- 初回のみ必要なら `Sources/App/Presentation/Core/ViewStateProtocol.swift`
- 初回のみ必要なら `Sources/App/Presentation/Core/EffectHandlingView.swift`

## ワークフロー

1. 入力を確認する
   - 入力: `docs/usecases/<ScreenName>/<ScreenName>.md`、`docs/usecases/<ScreenName>/<ScreenName>.pen`（存在時）、`docs/usecases/<ScreenName>/viewScript.md`（任意）
   - 実施内容: 対象画面の仕様ファイルを読み、`.pen` の有無を判定する。`.pen` があれば必ず読み、読めない場合は実装を止めて確認事項を明確化する。
   - 実施ルール:
     - `.pen` があるのに未読で実装を開始しない
     - `.pen` が壊れている場合は推測実装しない
   - 実装パターン: この手順は確認フェーズのため、コード追加は行わず入力整合のみ確認する

2. UI要件を正規化する
   - 入力: `docs/usecases/<ScreenName>/<ScreenName>.md`、`.pen`（存在時）
   - 実施内容: `UI要素` `UI状態` `UIイベント` を抽出し、View実装に必要な部品・状態・操作へ落とし込む。`.md` と `.pen` が競合する場合は意味と見た目で優先順位を分離して判断する。
   - 実施ルール:
     - 操作意味・業務要件は `.md` を優先する
     - 見た目・階層・配置は `.pen` を優先する
     - 仕様にないUI操作を追加しない
   - 実装パターン: この手順は設計フェーズのため、抽出結果を実装前チェック観点として整理する

3. View本体を実装する
   - 入力: 手順2の抽出結果、既存コード
   - 実施内容: 画面Viewを実装し、UseCase発火とEffect反映を接続する。必要なら初回のみ共通プロトコルを作成する。
   - 実施ルール:
     - `View` は `EffectHandlingView` に適合させる
     - `@Environment(\.<screen>UseCase)` と `@Environment(AppState.self)` を使用する
     - `@State private var viewState = <ScreenName>ViewState()` を保持する
     - Observerが必要な画面は `@Environment(<ScreenName>Observer.self)` を使う
     - ユーザー操作は `handle { await useCase.xxx() }` 経由で発火する
     - アラート表示中のボタン結果は `handle { await useCase.handleAlertResult(alertEffect, buttonType: buttonType) }` でUseCaseへ戻す
     - アラートUIを持つ画面では `handleAlertResult` への接続を省略しない
     - 長押し/スワイプなどの操作種別を無断で変更しない
   - 実装パターン:

     ```swift
     import SwiftUI

     struct TaskListView: View, EffectHandlingView {
         @Environment(\.taskListUseCase) private var useCase
         @Environment(AppState.self) private var appState
         @Environment(TaskListObserver.self) private var observer

         @State private var viewState = TaskListViewState()

         var body: some View {
             List(observer.dataList) { task in
                 Text(task.title.value)
             }
             .bindAlert(alertState: $viewState.alertState) { alertEffect, buttonType in
                 handle {
                     await useCase.handleAlertResult(alertEffect, buttonType: buttonType)
                 }
             }
             .task { handle { await useCase.fetchTasks() } }
         }
     }
     ```

4. 共通プロトコルの不足を補う
   - 入力: `Sources/App/Presentation/Core/ViewStateProtocol.swift` と `Sources/App/Presentation/Core/EffectHandlingView.swift` の有無、既存実装、`skills/swiftui-view-implementation/references/ViewStateProtocol.swift`、`skills/swiftui-view-implementation/references/EffectHandlingView.swift`
   - 実施内容: ファイルが無い場合のみ、reference をそのままコピーして `Sources/App/Presentation/Core/ViewStateProtocol.swift` と `Sources/App/Presentation/Core/EffectHandlingView.swift` を作成する。
   - 実施ルール:
     - 既存定義がある場合は重複作成しない
     - 新規作成時は手書きで再構築せず、reference からコピペして開始する

5. 実装差分を検証する
   - 入力: 更新後の View ファイル、`docs/usecases/<ScreenName>/<ScreenName>.md`、`.pen`（存在時）
   - 実施内容: UI要件と実装を照合し、不足・過剰・操作種別の不一致を確認する。
   - 実施ルール:
     - `UI要素` にない操作UIを実装しない
     - `UIイベント` の操作種別を変更しない
     - `.pen` がある場合は主要階層と主要配置を維持する
   - 実装パターン: この手順は確認フェーズのため、差分確認観点のみ記録する

## チェックリスト

- `docs/usecases/<ScreenName>/<ScreenName>.md` の `UI要素` を全て実装した
- 実装した操作が `UIイベント` と同じ操作種別になっている
- `handle { await useCase.xxx() }` 経由でユーザー操作を発火している
- アラートUIを持つ画面で `handleAlertResult` が接続されている
- `ViewEffect` / `ScreenEffect` / `AlertEffect` が `Equatable` を満たしている
- `ViewState` 更新と `AppState` 更新の責務を分離できている
- `.pen` がある画面で主要階層・主要配置を維持している
- `Sources/App/Presentation/Core/ViewStateProtocol.swift` を重複定義していない
- `Sources/App/Presentation/Core/EffectHandlingView.swift` を重複定義していない
- `ViewStateProtocol.swift` を新規作成した場合、`references/ViewStateProtocol.swift` からコピペして開始している
- `EffectHandlingView.swift` を新規作成した場合、`references/EffectHandlingView.swift` からコピペして開始している
- `bindAlert` 実装（3種Alert分岐）を削除・改変していない
- View実装都合で `ViewState` に仕様外の補助メソッド・状態を追加していない
