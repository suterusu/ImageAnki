---
name: usecase-testing
description: |
  docs/usecases を仕様として、UseCase層のSwiftTestingを生成・更新するときに使う。
---

# UseCase Testing

## 概要

このタスクで何を行うか:

- `docs/usecases/*/*.md` を仕様として、UseCase層のテストを作成・更新する。
- 基本テストは通常DI（`AppDependencies.make(for: .test)`）を使ったIntegrationテストで実装する。
- Repository/DB起因の失敗系のみ、共通Failing Repositoryで再現して検証する。

入力:

- `docs/usecases/<ScreenName>/<ScreenName>.md`
- `Sources/App/Domain/UseCases/*.swift`
- `Sources/App/AppDependencies.swift`
- `Tests/Support/AsyncStream+TestSupport.swift`
- `Tests/Support/DomainObject+TestFactory.swift`
- `Tests/Support/Repositories/*.swift`

参照（テンプレート・ガイドライン）:

- `skills/usecase-testing/references/AsyncStream+TestSupport.swift` — 初回コピー元
- `skills/usecase-testing/references/DomainObject+TestFactory.swift` — Factory作成時の参考
- `skills/usecase-testing/references/Repositories/Repository_Failing_base.swift` — Failing Repository初回コピー元
- `skills/usecase-testing/references/Repositories/Repository_Failing_sample.swift` — Failing Repository追加時の参考
- `skills/_shared/RESPONSIBILITY_BOUNDARIES.md` — 責務境界の判断基準

出力:

- `Tests/UseCases/<UseCaseName>Tests.swift`
- `Tests/Support/AsyncStream+TestSupport.swift`（必要時のみ更新）
- `Tests/Support/DomainObject+TestFactory.swift`（必要時のみ更新）
- `Tests/Support/Repositories/Repository_Failing.swift`（Repositoryエラー試験が必要な場合のみ更新）

## フォルダ構成

```text
Sources/App/
├── AppDependencies.swift
├── Domain/
│   └── UseCases/
│       └── <UseCase>.swift
└── ...

Tests/
├── UseCases/
│   └── <UseCaseName>Tests.swift
└── Support/
    ├── AsyncStream+TestSupport.swift
    ├── DomainObject+TestFactory.swift
    └── Repositories/
        └── Repository_Failing.swift
```

- `Sources/App/Domain/UseCases`: テスト対象のUseCase本体を配置する。
- `Tests/UseCases`: 仕様トレース可能なUseCaseテストを配置する。
- `Tests/Support`: テスト補助（AsyncStream収集、Factory、Failing Repository）を集約する。

## ワークフロー

1. 必要共通ファイルを作成する(初回のみ)
   - 入力: `Tests/Support/*`
   - 実施内容: テストで使う共通ファイルを作成する。
   - 実施ルール:
     - `Tests/Support/AsyncStream+TestSupport.swift` が無ければ `skills/usecase-testing/references/AsyncStream+TestSupport.swift` からコピーして作成する
     - `Tests/Support/DomainObject+TestFactory.swift` が無ければ空ファイルとして作成する
     - `Tests/Support/Repositories/Repository_Failing.swift` が無ければ`skills/usecase-testing/references/Repositories/Repository_Failing_base.swift`からコピーして作成する

2. 仕様トレース対象を確定する
   - 入力: `docs/usecases/<ScreenName>/<ScreenName>.md`、`Sources/App/Domain/UseCases/*.swift`
   - 実施内容: ユースケース記述内の **全ユースケース**（`## ユースケースN`）について、`システムは` で始まる手順とUseCaseコードの1:1対応を確認し、検証対象を確定する。
   - 実施ルール:
     - ユースケース記述内の全 `## ユースケースN` を対象にする（一部だけ選んで省略しない）
     - `システムは` で始まる手順はUseCaseコードと1:1対応する。これが検証対象
     - `ユーザーは` で始まる手順はトリガー（入力）であり、テストのセットアップや呼び出しに使う
     - 各ユースケースの基本フロー・分岐フロー・例外フローすべてから検証対象を抽出する
     - 例外フローは `4-A` のように分岐元手順番号で追跡する
     - UseCase責務外（UI描画・文言変換）は検証対象に含めない
3. 基本テストを通常DIで実装する
   - 入力: 対象UseCase、`Sources/App/AppDependencies.swift`
   - 実施内容: `AppDependencies.make(for: .test)` をローカル変数に保持し、UseCase実行結果と永続化結果を検証する。
   - 実施ルール:
     - `let app = AppDependencies.make(for: .test)` のように一時値チェーンを避ける
     - `try!` と強制アンラップを使わず、テスト関数は `throws` で定義する
     - `ModelContext` 直接操作を避け、Repository経由でセットアップ/検証する
     - テストデータ生成が重複し始めたタイミングでのみ、`DomainObject+TestFactory.swift` を `skills/usecase-testing/references/DomainObject+TestFactory.swift` を参考に作成/更新する
     - `@Test` の表示名は `"ユースケースN: <ユースケース名> - <フロー名>"` の形式にする（例: `@Test("ユースケース1: 学習結果を確認する - 基本フロー")`）
     - テスト関数の直前に `// 仕様トレース: ユースケースN 手順X,Y,Z` コメントを付け、対応する `docs/usecases/<ScreenName>/<ScreenName>.md` のユースケース番号と手順番号を明示する
     - テスト本文は `// ── 前提: ～ ──`、`// ── 操作: ～（手順N） ──`、`// ── 検証 ──` の3セクションに分ける
     - 前提セクションではデータ準備の意図（どういうシナリオか）をコメントで説明する。前提がない場合は `// ── 前提: なし ──` と書く
     - 操作セクションではユースケースのどの手順をトリガーしているかを明示する
     - `#expect` メッセージにユースケース記述の手順番号と期待内容を `"手順X: 〜すること"` の形式で書く
     - `handleAlertResult` に処理がある場合はテストを行う
   - 実装パターン:

     ```swift
     // 仕様トレース: ユースケース1 手順6,7,8
     @Test("ユースケース1: 単語を作成する - 基本フロー")
     @MainActor
     func create_success() async throws {
         let app = AppDependencies.make(for: .test)
         let useCase = app.createWordUseCase
         let repository = app.vocabularyCardRepositoryForTest

         // ── 前提: なし ──

         // ── 操作: 単語を作成する（手順6） ──
         let effects = await (await useCase.createWord(term: "term", meaning: "meaning")).collectAll()

         // ── 検証 ──
         let stored = try await repository.fetchAll()
         #expect(effects.first == .screen(.showLoading), "手順6: showLoadingを返すこと")
         #expect(stored.count == 1, "手順7: 1件保存されること")
     }
     ```

4. Failing Repositoryを作成する（Repository/DB起因の失敗試験がある場合のみ）
   - 入力: `Tests/Support/Repositories/Repository_Failing.swift`、`skills/usecase-testing/references/Repositories/Repository_Failing_sample.swift`
   - 実施内容: DB内部起因の失敗を強制的に再現する専用のRepositoryを `Tests/Support/Repositories/Repository_Failing.swift` に追加する。
   - 実施ルール:
     - `skills/usecase-testing/references/Repositories/Repository_Failing_sample.swift` を参考に必要なリポジトリクラスに強制失敗版を追加していく
     - 基本処理は `BaseRepository_Failing<Element>`（`typealias Domain = Element` を明示）に適合させる
     - Repository独自メソッドが必要な場合のみ `extension` で自力実装する
     - Failing Repositoryをテストローカルに乱立させずSupportへ集約する

5. Failing Repositoryを使ってRepository内部エラーのテストを記述する
   - 入力: 対象UseCase、手順4で作成したFailing Repository
   - 実施内容: Failing Repositoryを注入してUseCaseを実行し、ViewEffect（`.screen(...)` / `.alert(...)`）の順序と内容を検証する。
   - 実施ルール:
     - ステップ3の仕様トレースルール（`仕様トレース:` コメント、`#expect` の手順番号、分割検証の明記）も適用する
     - Failing RepositoryはRepository/DB起因の失敗試験でのみ使う
   - 実装パターン:

     ```swift
     // 仕様トレース: ユースケース1 例外フローC 手順1-C,2-C,3-C
     @Test("ユースケース1: カードを読み込む - 例外フローC: 読み込みに失敗する")
     @MainActor
     func load_error() async {
         // ── 前提: Repositoryが常に失敗する ──
         let useCase = StudyUseCase(vocabularyCardRepository: VocabularyCardRepository_Failing())

         // ── 操作: カードを読み込む ──
         let effects = await (await useCase.loadCards()).collectAll()

         // ── 検証 ──
         #expect(effects == [.screen(.showLoading), .alert(.showError(.fetchFailed)), .screen(.hideLoading)],
                 "手順2-C: 取得失敗時にエラー表示後、ローディングを閉じること")
     }
     ```

6. テスト実行と結果確認を行う
   - 入力: 更新後のテスト一式
   - 実施内容: `build-for-testing` → `test` の順で実行し、結果を確認する。
   - 実施ルール:
     - destination は `xcodebuild -showdestinations` で利用可能なシミュレータを確認してから指定する（`iPhone 16` 固定にしない）
     - まず `xcodebuild build-for-testing` を実行し、テストビルドが通ることを確認する
     - ビルド成功後に `xcodebuild test` を実行する
     - sandbox制約で `test` が実行不能な場合は、`build-for-testing` 成功を最低限の完了条件とする
     - 失敗時は仕様トレースと期待値メッセージの整合を優先確認する
     - 依頼範囲外（UseCase以外）のテストは追加しない

## チェックリスト

- 概要に「このタスクで何を行うか / 入力 / 出力」が揃っている
- フォルダ構成に入力と出力の配置先が示されている
- すべての手順が「入力 / 実施内容 / 実施ルール / 実装パターン」で記述されている
- ワークフロー先頭で必要ファイルの設定を行う構成になっている
- ワークフロー先頭でコピペ必須なのは `AsyncStream+TestSupport.swift` のみになっている
- 基本テストが通常DI（`AppDependencies.make(for: .test)`）で実装されている
- Repository/DB起因の失敗系のみFailing Repositoryを使うルールになっている
- `#expect` メッセージが仕様手順番号に紐づいている
- 全UseCaseのpublicメソッドに対して、対応するテストが最低1件ずつ存在している
- 例外フローを持つメソッドは、失敗系テスト（Repository/DB起因を含む）が存在している
