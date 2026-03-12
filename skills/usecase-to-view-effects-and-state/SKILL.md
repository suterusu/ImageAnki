---
name: usecase-to-view-effects-and-state
description: |
  `docs/usecases/<ScreenName>/<ScreenName>.md` を基準に、画面単位の ScreenEffect / AlertEffect / ViewEffect と ViewState（apply(_:)）を一気通貫で実装・更新するときに使う。
---

# Usecase To ViewEffects And ViewState

## 概要

- このタスクで何を行うか:
  - 1画面単位で `ScreenEffect` / `AlertEffect` / `ViewEffect` を整合した形で実装する
  - `ViewEffect -> ViewState.apply(_:)` の反映ルールを仕様準拠で定義する
- 入力:
  - 必須: `docs/usecases/<ScreenName>/<ScreenName>.md`
  - 任意: `docs/usecases/<ScreenName>/<ScreenName>.pen`
  - 任意: `docs/usecases/<ScreenName>/penScript.md`
  - 任意: `docs/usecases/<ScreenName>/viewScript.md`
  - 補助: `Sources/App/Domain/Errors/*`
- 出力:
  - `Sources/App/Domain/ViewEffects/<ScreenName>ViewEffect.swift`
  - `Sources/App/Presentation/ViewStates/<ScreenName>ViewState.swift`

## ワークフロー

1. ユースケース記述から ViewEffect を定義する
   - 入力:
     - `docs/usecases/<ScreenName>/<ScreenName>.md`
     - 必要時: `Sources/App/Domain/Errors/*`
   - 実施内容:
     - ユースケース本文と `UIイベント` から副作用を抽出し、`<ScreenName>ScreenEffect` と `<ScreenName>AlertEffect` のケースへ分割する。
     - ラッパー `ViewEffect<ScreenEffect, AlertEffect>` を使って `<ScreenName>ViewEffect`（typealias）を定義する。
     - `Sources/App/Domain/ViewEffects/<ScreenName>ViewEffect.swift` を作成または更新する。
   - 実施ルール:
     - ケース名は動詞開始で統一する
     - `ScreenEffect` は `showLoading` / `hideLoading` / `navigate...` など通常UI更新を担当する
     - `AlertEffect` は確認/警告/エラーなどアラート表示の意味のみを担当する
    - `ScreenEffect` は `Equatable` / `Sendable` かつ `AppEffectConvertible` に適合させる
    - `AlertEffect` は `Equatable` / `Sendable` に適合させる
    - `ViewEffect` は `ViewEffect<ScreenEffect, AlertEffect>` を通じて `Equatable` を満たす前提で扱う
     - **Equatable適合ルール:**
       1. 自動合成できる型設計を優先する（例: `Error` の関連値を持たない `UseCaseError`）
       2. 自動合成できない associated value が必要な場合のみ、`static func ==` を手動実装する
       3. 手動実装では、比較不能な情報（`Error` 本体など）は比較対象から除外し、ケース同値で判定する方針を明示する
     - ユースケース記述に根拠のない Effect を追加しない
   - 実装パターン:

     ```swift
     public enum <ScreenName>ScreenEffect: Equatable, Sendable {
         case showLoading
         case hideLoading
         case showEmptyState
         case clearInput
         case navigateToNext
     }

     public enum <ScreenName>AlertEffect: Equatable, Sendable {
         case showError(<ScreenName>Error)
         case confirmDelete(itemID: UUID)
     }

     public typealias <ScreenName>ViewEffect = ViewEffect<<ScreenName>ScreenEffect, <ScreenName>AlertEffect>

     extension <ScreenName>ScreenEffect: AppEffectConvertible {
         public func asAppEffect() -> AppEffect { .<screenName>(self) }
     }
     ```

2. UI状態とデザイン補助情報から ViewState を定義する
   - 入力:
     - `docs/usecases/<ScreenName>/<ScreenName>.md`（`UI状態` を最優先）
     - 補助: `docs/usecases/<ScreenName>/<ScreenName>.pen` / `penScript.md` / `viewScript.md`
   - 実施内容:
     - `UI状態` を起点に、必要な状態だけを `ViewState` のプロパティへ落とし込む。
     - 任意入力は命名や粒度の補正にだけ使い、仕様の主語は常にユースケース記述に置く。
   - 実施ルール:
     - 仕様根拠のない状態プロパティを追加しない
     - 代表変換は `isLoading: Bool`, `show...: Bool`, `input...: String` を優先する
     - アラートを使う画面では `alertState: AlertState<<ScreenName>AlertEffect>?` を採用する
     - 画面遷移自体を表す状態を ViewState に持たせない
   - 実装パターン:
     - 実装フェーズでは `ScreenEffect` と `AlertEffect` を分けて対応表を作ってからコード化する

3. ViewEffect を apply(\_:) で ViewState へ反映する
   - 入力:
     - `Sources/App/Domain/ViewEffects/<ScreenName>ViewEffect.swift`
     - `Sources/App/Presentation/ViewStates/<ScreenName>ViewState.swift`
   - 実施内容:
     - `ViewStateProtocol` 準拠の `apply(_:)` を実装する。
     - `.screen(...)` は通常のUI状態更新、`.alert(...)` は `alertState` 生成へ振り分ける。
   - 実施ルール:
     - 遷移系 `ScreenEffect`（`navigate...` / `dismiss...`）は `break` とし、AppState責務に残す
     - `AlertEffect` から `AlertState` を生成する `makeAlertState(from:)` を ViewState で実装する
     - 1画面1ViewStateを維持し、他画面の状態を混在させない
   - 実装パターン:

     ```swift
     @MainActor
     @Observable
     final class <ScreenName>ViewState: ViewStateProtocol {
         var isLoading: Bool = false
         var alertState: AlertState<<ScreenName>AlertEffect>?

         func apply(_ effect: <ScreenName>ViewEffect) {
             switch effect {
             case .screen(.showLoading):
                 isLoading = true
             case .screen(.hideLoading):
                 isLoading = false
             case .screen(.navigateToNext):
                 break
             case .screen:
                 break
             case .alert(let alertEffect):
                 alertState = makeAlertState(from: alertEffect)
             }
         }

         func makeAlertState(from effect: <ScreenName>AlertEffect) -> AlertState<<ScreenName>AlertEffect> {
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
             case .confirmDelete(let itemID):
                 _ = itemID
                 return AlertState(
                     alertEffect: effect,
                     alertType: .destructiveConfirmation,
                     title: "削除確認",
                     message: "削除しますか？",
                     buttonTitle: "削除",
                     cancelButtonTitle: "キャンセル"
                 )
             }
         }

         private func errorMessage(for error: <ScreenName>Error) -> String {
             switch error {
             case .validationFailed:
                 return "入力内容を確認してください。"
             case .saveFailed:
                 return "保存に失敗しました。"
             case .unknown:
                 return "エラーが発生しました。"
             }
         }
     }
     ```

4. 生成結果を網羅チェックする
   - 入力:
     - 更新後の `ViewEffect.swift` / `ViewState.swift`
     - `docs/usecases/<ScreenName>/<ScreenName>.md`
   - 実施内容:
     - 仕様と実装差分を照合し、不足と過剰を判定する。
   - 実施ルール:
     - `UI状態` の全項目が ViewState で表現できること
     - ViewEffect 全ケースの取り扱いが `apply(_:)` で明示されること
     - 責務境界の最終判定は `skills/_shared/RESPONSIBILITY_BOUNDARIES.md` を優先すること
   - 実装パターン:
     - この手順は確認フェーズのため、コード追加は行わず確認観点のみ記述する

## チェックリスト

- `<ScreenName>ScreenEffect` と `<ScreenName>AlertEffect` が責務分離されている
- `<ScreenName>ViewEffect` が `ViewEffect<ScreenEffect, AlertEffect>` の typealias で定義されている
- `ScreenEffect` が `AppEffectConvertible` に適合している
- `UI状態` の項目が `ViewState` プロパティとして過不足なく反映されている
- 遷移系 `ScreenEffect` を `ViewState.apply(_:)` で状態更新していない
- 仕様根拠のない Effect / State を追加していない
