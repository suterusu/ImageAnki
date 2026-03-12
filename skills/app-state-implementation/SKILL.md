---
name: app-state-implementation
description: |
  AppState（@Observable）を生成するスキル（SwiftUIアプリ用）。
  `docs/ScreenFlow.md` のナビゲーションツリーと ScreenEffect から画面遷移を処理し、アプリ全体の状態を管理する。
---

# AppState Implementation

## 概要

このタスクで何を行うか:
- アプリ全体で1つ保持する状態管理クラス（AppState）を生成する。
- 画面遷移（NavigationPath）とタブ状態（selectedTab）だけを担当する。
- AppEffect / Screen / AppTab も同一ファイルに定義する。

入力:
- `docs/ScreenFlow.md` — ナビゲーションツリー（タブ構成・画面階層・遷移ルール）
- `Sources/App/Domain/ViewEffects/*ViewEffect.swift`

参照（テンプレート・ガイドライン）:
- `skills/app-state-implementation/references/AppState_example.swift` — 実装パターンの参考
- `skills/_shared/RESPONSIBILITY_BOUNDARIES.md` — 責務境界の判断基準

出力:
- `Sources/App/Presentation/AppState.swift`（AppEffect / Screen / AppTab を含む）

## ワークフロー

1. ScreenFlow.mdからナビゲーション構造を読み取る
   - 入力: `docs/ScreenFlow.md`
   - 実施内容: ナビゲーションツリーを読み、AppTab・Screen enum・タブごとのスタック深度を確定する。
   - 実施ルール:
     - ツリーのルート直下の子がタブ（AppTab）になる
     - ツリーの各ノードがScreen enumのケースになる
     - 遷移操作は2種類のみ: `popToRoot → push`（ツリーのパスに沿う）と `switchTab`
   - 実装パターン: この手順は確認フェーズのため、コード追加は行わず構造のみ確定する

2. ScreenEffectから画面遷移・タブ切替を抽出する
   - 入力: `Sources/App/Domain/ViewEffects/*ViewEffect.swift`、`skills/_shared/RESPONSIBILITY_BOUNDARIES.md`
   - 実施内容: 各画面の `ScreenEffect` enum を読み、AppStateが処理すべき遷移系ケースを抽出する。`AlertEffect` はAppStateの責務外のため無視する。
   - 実施ルール:
     - `ScreenEffect` の画面遷移系（navigate / dismiss）のみ抽出する
     - ローディング・エラー表示など画面固有UI状態はViewStateの責務として除外する
   - 抽出基準:

     | 種類 | ScreenEffectの例 | AppStateでの処理 |
     |------|----------------|-----------------|
     | 画面遷移 | `navigateToStudyCard(words:)` | ツリーのパスに沿って `popToRoot → push` |
     | タブ切替+遷移 | `navigateToStudyCard` (成績タブから) | `switchTab` + 切替先で `popToRoot → push` |

   - 実装パターン: この手順は確認フェーズのため、コード追加は行わず対象ケースのみ確定する

3. AppState.swift を生成する
   - 入力: 手順1のナビゲーション構造、手順2で抽出したケース一覧、`skills/app-state-implementation/references/AppState_example.swift`
   - 実施内容: `Sources/App/Presentation/AppState.swift` に AppTab / Screen / AppEffectConvertible / AppEffect / AppState をまとめて生成する。
   - 実施ルール:
     - `@MainActor @Observable public final class AppState`
     - `navigationPath` と `selectedTab` のみ保持する
     - `apply(_ effect: AppEffect)` で画面遷移系のみ処理する
     - 画面遷移以外のケースは `default: break` で無視する
     - `removeLast()` 呼び出し前に空チェックを行う
     - UseCaseを直接呼ばない（UseCase実行はView側）
     - Environmentで注入される
   - 実装パターン:
     ```swift
     import SwiftUI
     import Observation

     // MARK: - AppTab
     public enum AppTab: Hashable {
         case taskList
         case settings
     }

     // MARK: - Screen
     public enum Screen: Hashable {
         case createTask
         case editTask(id: UUID)
     }

     // MARK: - AppEffect
     public protocol AppEffectConvertible: Sendable {
         func asAppEffect() -> AppEffect
     }

     public enum AppEffect {
         case taskList(TaskListScreenEffect)
         case create(CreateTaskScreenEffect)
     }

     // MARK: - AppState
     @MainActor
     @Observable
     public final class AppState {
         public var selectedTab: AppTab = .taskList
         public var navigationPath = NavigationPath()

         public init() {}

         public func apply(_ effect: AppEffect) {
             switch effect {
             case .taskList(let effect):
                 switch effect {
                 case .navigateToCreateTask:
                     navigationPath.append(Screen.createTask)
                 default:
                     break
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
             }
         }
     }
     ```

4. 生成結果を検証する
   - 入力: 生成済みファイル、各画面のScreenEffect
   - 実施内容: 全画面遷移ケースの網羅性、責務境界の一致を確認する。
   - 実施ルール:
     - AppStateにローディング・エラー表示などの画面固有UI状態を持たせていない
     - AppStateからUseCaseを呼んでいない
     - すべての画面遷移系ScreenEffectがAppEffect/applyで処理されている
     - removeLast前の空チェックが漏れていない
   - 実装パターン: この手順は確認フェーズのため、差分確認観点のみ記録する

## チェックリスト

- 概要に「このタスクで何を行うか / 入力 / 出力」が揃っている
- すべての手順が「入力 / 実施内容 / 実施ルール / 実装パターン」で記述されている
- AppState が `@MainActor @Observable` で定義されている
- AppState が `navigationPath` と `selectedTab` のみ保持している
- `apply(_:)` で画面遷移系のみ処理し、それ以外は `default: break` している
- AppEffect が全画面のScreenEffectを統合している
- Screen enum が `Hashable` に適合している
- AppState から UseCase を直接呼んでいない
- `removeLast()` 前に空チェックがある
