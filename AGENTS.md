運用ルール

## Skill変更履歴ポリシー

- `skills/*/SKILL.md` に変更履歴セクションは持たない。
- Skillの変更履歴はGitコミットで管理する。

## Skill配置ポリシー（Claude/Codex互換）

- Skill実体はトップレベルの `skills` に置く。
- Claude/Codex互換のため `.claude/skills` と `.agents/skills` の両方から同一Skillを参照できる状態を維持する。
- 推奨実装はシンボリックリンク（`.claude/skills -> ../skills`、`.agents/skills -> ../skills`）。

## iOS単語帳アプリ作成フロー

### 実行方針

- 基本的には `フロー1` または `フロー2` のどちらか一方を実行する。
- `フロー1` の成果物（`docs/usecases` / `docs/domain/cards`）が揃っている場合は `フロー2` を実行する。
- 同一依頼で両方を連続実行するのは、ユーザーが明示した場合のみとする。
- `フロー1+` は特殊な任意フローとし、やれたらやる（best effort）で扱う。
- `フロー1+` は `フロー1` 完了後に実施可否をユーザーへ確認してから実行する。

### フロー1: 要求からドキュメント作成

1. `usecase-description-authoring` を基準に、画面ごとの `docs/usecases/<ScreenName>/<ScreenName>.md` を作成・更新し、同階層に `penScript.md`（初期は空）と `viewScript.md`（初期は空）を作成
2. `usecase-to-domain-cards` を基準に、`docs/usecases/<ScreenName>/<ScreenName>.md` からドメイン候補を抽出し、`docs/domain/cards/*.md` を作成
3. `usecase-description-authoring` を基準に、`docs/usecases/<ScreenName>/<ScreenName>.md` 内へ UI要素・UI状態・UIイベント発火条件を追記

### フロー1+: ユースケースから画面 .pen 作成（任意）

1. `usecase-to-screen-image` を基準に、`docs/usecases/<ScreenName>/<ScreenName>.md` と `penScript.md` から Pencil への依頼内容を作成
2. Pencil に「iOSの画面を作成してくれ」と依頼し、同階層へ `docs/usecases/<ScreenName>/<ScreenName>.pen` を作成
3. このフローは任意であり、未実施でもフロー1/2の完了条件には影響しない

### フロー2: ドキュメントからコード実装

1. `domain-cards-to-swift` を基準に、`Sources/App/Domain` 配下へ Entity / Value Object / Repository / Core を実装
2. `usecase-to-view-effects-and-state` と `error-implementation` を基準に、画面ごとの `ViewEffect` / `ViewState` / `UseCaseError` を定義
3. `usecase-implementation` を基準に、`AsyncStream<ViewEffect>` を返す UseCase（Unimplemented版含む）を実装
4. `repository-implementation` を基準に、SwiftData PersistentModel / BiMapper / Repository を実装し、必要な Observer を追加
5. `swiftui-view-implementation` を基準に、View で `handle({ await useCase.xxx() })` を使う画面実装を作成
6. `app-state-implementation` と `root-view` を基準に、`AppState` と `RootView` の遷移管理を実装
7. `app-dependencies` を基準に、`AppDependencies` と `EnvironmentValues` 注入、`@main App` のDI配線を実装
8. `usecase-testing` を基準に、UseCase中心のテストを追加してから `xcodebuild` でビルド検証
9. `ios-project-bootstrap` を基準に、`xcodeproj` が未作成の場合のみ初回ブートストラップを実施
