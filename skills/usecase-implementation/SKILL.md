---
name: usecase-implementation
description: |
  ユースケース記述とドメインモデル、ScreenEffect / AlertEffect / ViewEffect からユースケース実装を生成するスキル（Swiftアプリ用）。
  Protocol + Struct実装パターンで、AsyncStreamでViewEffectを返す形式で実装する。

  実装パターン:
  - バリデーションエラー: ローディング前に処理、UseCaseErrorをAlertEffect経由で発行して終了
  - 非同期処理: ローディング表示 → 処理 → ローディング非表示
  - キャンセル: CancellationErrorは何も出さずに終了
  - エラー: UseCaseErrorをAlertEffectで発行（ViewStateがAlertStateへ変換）
---

# Usecase Implementation

## 概要

このタスクで何を行うか:

- `docs/usecases/*/*.md` とドメインモデル、ScreenEffect / AlertEffect / ViewEffect を入力に、画面単位でUseCaseを実装する。
- 1画面につき1つのUseCaseProtocol + 実装struct + Unimplemented版を生成する。
- 全メソッドは `AsyncStream<<ScreenName>ViewEffect>` を返す。

入力:

- `docs/usecases/<ScreenName>/<ScreenName>.md`
- `Sources/App/Domain/Entities/*.swift`
- `Sources/App/Domain/Core/ViewEffect.swift`（共通 `ViewEffect` 定義）
- `Sources/App/Domain/ViewEffects/<ScreenName>ViewEffect.swift`（`<ScreenName>ScreenEffect` / `<ScreenName>AlertEffect` / `<ScreenName>ViewEffect` typealias — `usecase-to-view-effects-and-state` で定義済み）
- `Sources/App/Domain/Repositories/*Repository.swift`

参照（テンプレート・ガイドライン）:

- `skills/usecase-implementation/references/*` — 実装パターンの参考
- `skills/_shared/RESPONSIBILITY_BOUNDARIES.md` — 責務境界の判断基準

出力:

- `Sources/App/Domain/UseCases/<ScreenName>UseCase.swift`（Protocol + Unimplemented + 実装struct + UseCaseError）
- 初回のみ: `Sources/App/Domain/Core/ViewEffect.swift`
- 初回のみ: `Sources/App/Domain/Core/EffectStream.swift`

## ワークフロー

1. ViewEffectを配置する（初回のみ）
   - 入力: `skills/usecase-implementation/references/ViewEffect.swift`
   - 実施内容: `Sources/App/Domain/Core/ViewEffect.swift` が未存在の場合、referenceを最初にそのままコピペして配置する。

2. ユースケースから操作を抽出する
   - 入力: `docs/usecases/<ScreenName>/<ScreenName>.md`、`skills/_shared/RESPONSIBILITY_BOUNDARIES.md`
   - 実施内容: 各 `## ユースケースN` から操作名・入力パラメータ・使用ドメインモデル・副作用を抽出する。
   - 実施ルール:
     - `## ユースケースN` 1件につきメソッド1つ（1:1）
     - 「前の画面へ戻る」のみでOS標準戻るで成立するユースケースは実装対象外
     - UI文言変換はViewState、画面遷移実行はAppStateの責務
   - 実装パターン: この手順は確認フェーズのため、コード追加は行わず対象メソッドのみ確定する

3. EffectStreamを配置する（初回のみ）
   - 入力: `skills/usecase-implementation/references/EffectStream.swift`
   - 実施内容: `Sources/App/Domain/Core/EffectStream.swift` が未存在の場合、参考コードから配置する。
   - 実施ルール:
     - `EffectStream.make { yield in ... }` 形式で利用する
     - `onTermination` / `finish()` を手動配線しない
   - 実装パターン:
     ```swift
     public enum EffectStream {
         @MainActor
         public static func make<Effect: Sendable>(
             _ build: @MainActor @escaping (@MainActor @escaping (Effect) -> Void) async -> Void
         ) -> AsyncStream<Effect> { ... }
     }
     ```

4. UseCaseファイルを生成する
   - 入力: 手順2の抽出結果、ScreenEffect / AlertEffect / ViewEffect、Repository、`skills/usecase-implementation/references/TaskListUseCaseClient_example.swift`
   - 実施内容: `Sources/App/Domain/UseCases/<ScreenName>UseCase.swift` に Protocol + Unimplemented + 実装struct + UseCaseError をまとめて生成する。
   - 実施ルール:
     - メソッド内の処理ステップとユースケース記述のフロー手順（`システムは ...`）と基本1:1で対応させる
     - メソッド本文中に `// 手順N: 〜` コメントを付け、ユースケース記述のどの手順に対応するコードかを明示する
     - UseCaseはアプリケーション層の調停（オーケストレーション）だけを担当し、ビジネスロジックは持たない
     - 判定・計算・整合性保証などのドメインルールは Entity / ValueObject / DomainService に委譲する
     - private メソッドを追加しない。処理はすべて public メソッド内にインラインで記述する
     - Protocol: `@MainActor`
     - 全メソッド: `func xxx(...) async -> AsyncStream<<ScreenName>ViewEffect>`
     - アラート→ボタン操作の2段階フロー: (1) メソッド内で `yield(.alert(.confirmXxx(...)))` を発行してアラートを表示する (2) 利用者がボタンを押すと `.confirmXxx(...)` と `ButtonType` が `handleAlertResult` に渡される (3) `handleAlertResult` 内で `.confirmXxx(...)` の種類と `ButtonType` を switch して後続処理を実行する
     - 全UseCase Protocolに `func handleAlertResult(_ alertEffect: <ScreenName>AlertEffect, buttonType: ButtonType) async -> AsyncStream<<ScreenName>ViewEffect>` を必ず追加する
     - `handleAlertResult` は最低限 no-op 実装（`switch` して `break`）でも可とする
     - Unimplemented版: 全メソッド `fatalError()`、`init` は `nonisolated`（@Entry連携のため）
     - 実装struct: Repository依存をコンストラクタ注入で受ける
     - UseCaseError: UseCaseと同じファイルに定義（`error-implementation` 参照）
     - エラーは `throw` せず `yield(.alert(.showError(UseCaseError)))` で発行する
     - `showLoading` と `hideLoading` は `yield(.screen(.showLoading))` / `yield(.screen(.hideLoading))` で対にする
   - 実装パターン:

     ```swift
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

         // 非同期処理パターン
         public func fetchTasks() async -> AsyncStream<TaskListViewEffect> {
             EffectStream.make { yield in
                 yield(.screen(.showLoading))
                 defer { yield(.screen(.hideLoading)) }
                 do {
                     // 手順2: タスク一覧を読み込む
                     let tasks = try await taskRepository.fetchAll()
                     // 手順3: タスク一覧を表示する
                     yield(.screen(tasks.isEmpty ? .showEmptyState : .refreshList(tasks)))
                 } catch {
                     yield(.alert(.showError(.fetchFailed)))
                 }
             }
         }

         // バリデーション失敗パターン（ローディング前に終了）
         public func createTask(title: String) async -> AsyncStream<TaskListViewEffect> {
             EffectStream.make { yield in
                 let task: Task
                 switch Task.make(title: title) {
                 case let .success(created): task = created
                 case let .failure(error):
                     yield(.alert(.showError(.validationFailed(error))))
                     return
                 }
                 yield(.screen(.showLoading))
                 defer { yield(.screen(.hideLoading)) }
                 do {
                     try await taskRepository.insert(task)
                     yield(.screen(.clearInput))
                 } catch {
                     yield(.alert(.showError(.createFailed)))
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
                 case (.confirmDelete(let id), .confirm):
                     // 手順N: 削除を確定する
                     // TODO: try await taskRepository.delete(id)
                     yield(.screen(.showLoading))
                     defer { yield(.screen(.hideLoading)) }
                 }
             }
         }
     }
     ```

5. 生成結果を検証する
   - 入力: 生成済みファイル、ユースケース記述
   - 実施内容: 1画面1UseCase、メソッド対応、エラーハンドリングの整合を確認する。
   - 実施ルール:
     - 1ユースケース記述1メソッドを満たしている（OS標準戻るのみは除外）
     - すべて `AsyncStream<<ScreenName>ViewEffect>` を返している
     - バリデーション失敗はローディング前に処理している
     - `showLoading` / `hideLoading` が対になっている
     - 責務境界の最終確認を `skills/_shared/RESPONSIBILITY_BOUNDARIES.md` で実施する
   - 実装パターン: この手順は確認フェーズのため、差分確認観点のみ記録する

## チェックリスト

- `ViewEffect.swift` を新規作成した場合、referenceからコピペで開始している
- 1画面1UseCaseを満たしている
- 1ユースケース記述1メソッドを満たしている（OS標準戻るのみは除外）
- すべて `AsyncStream<<ScreenName>ViewEffect>` を返している
- Protocol が `@MainActor`
- Unimplemented版が `fatalError()` で `init` が `nonisolated`
- Repository依存がコンストラクタ注入
- UseCaseError が UseCase と同じファイルに定義されている
- エラーを `throw` せず `yield(.alert(.showError(...)))` で発行している
- `showLoading` / `hideLoading` を `yield(.screen(...))` で対にして発行している
- 全UseCaseで `handleAlertResult(_ alertEffect:..., buttonType:...)` を実装している
- UseCaseがビジネスロジックを持たず、ドメインルールを Entity / ValueObject / DomainService に委譲している
- メソッド本文中に `// 手順N: 〜` コメントでユースケース記述との対応が明示されている
- private メソッドが追加されていない（処理はすべて public メソッド内にインライン）
