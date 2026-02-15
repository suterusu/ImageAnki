# ImageAnki

中学生向けの必修英単語（中1/中2/中3）を、カード学習でテンポよく覚えられる iOS アプリ。

このリポジトリは **Claude Code のスキル（Skills）だけで iOS アプリを構築する実験プロジェクト**でもある。ユースケース駆動設計をベースに、要求定義からコード生成・テストまでの全工程をスキルとして定義し、再現可能なパイプラインにしている。
※このリポジトリにskillsは含まれていないです。

## 設計思想

### ユースケース駆動で仕様とコードを 1:1 にする

ユースケース記述（ユーザーとシステムのやりとりを手順で記述したもの）を全工程の Source of Truth にしている。

```
ユースケース記述 → ドメインモデル → コード実装 → テスト
```

各工程の成果物がユースケース記述の手順番号でトレースできるため、「この実装はどの仕様に対応するのか」「この仕様はテストされているか」が常に追跡可能になる。

### UseCase が ViewEffect を返す

ユースケース層と仕様の 1:1 対応を保つために、UseCase は `AsyncStream<ViewEffect>` を返す設計にしている。

```swift
public func loadResult(sessionID: UUID) async -> AsyncStream<StudyResultScreenViewEffect>
```

これにより UseCase は **何が起きたかをイベントとして通知するだけ**に徹し、ViewState の更新や画面遷移の制御は担当しない。仕様の「システムは〜する」をそのまま ViewEffect の発行に対応させることで、ユースケース記述と実装コードの 1:1 対応を維持しやすくなる。

| レイヤー | 責務 |
|---|---|
| UseCase | ユースケース実行。Repository 呼び出し → ViewEffect 発行 |
| ViewEffect | 副作用イベントの列挙（表示系・遷移系） |
| ViewState | ViewEffect を受けて UI 状態を更新。エラー文言の変換もここ |
| AppState | 画面遷移系 Effect の処理。NavigationPath 管理 |
| View | ViewState の描画と入力イベントの送信 |

### ドメインカードで中間表現を挟む

ユースケース記述から直接 Swift コードを生成するのではなく、間に**ドメインカード**（Markdown 形式の Entity / Value Object / Repository 定義）を挟んでいる。

```
ユースケース記述 → ドメインカード(*.md) → Swift コード
```

ドメインカードがあることで、複数画面にまたがるドメイン概念の整合性をコード生成前に確認できる。

## スキルパイプライン
※このリポジトリにskillsは含まれていないです。

全 15 スキルが 2 つのフローに分かれている。

### フロー 1: 要求 → ドキュメント

| 順序 | スキル | やること |
|---|---|---|
| 1 | `usecase-description-authoring` | 画面ごとのユースケース記述を作成 |
| 2 | `usecase-to-domain-cards` | ユースケースからドメインカードを抽出 |
| 1+ | `usecase-to-screen-image` | ユースケースの UI 情報から `.pen` 画面モックを作成（任意） |

### フロー 2: ドキュメント → コード

| 順序 | スキル | やること |
|---|---|---|
| 1 | `domain-cards-to-swift` | ドメインカードから Entity / Value Object / Repository Protocol を生成 |
| 2 | `usecase-to-view-effects-and-state` | ViewEffect と ViewState を定義 |
| 2 | `error-implementation` | 各レイヤーのエラー型を定義 |
| 3 | `usecase-implementation` | UseCase の実装（Protocol + Struct + Unimplemented） |
| 4 | `repository-implementation` | SwiftData による Repository 実装と BiMapper |
| 5 | `swiftui-view-implementation` | SwiftUI View の実装 |
| 6 | `app-state-implementation` | AppState（画面遷移管理）の実装 |
| 6 | `root-view` | RootView と NavigationStack の構成 |
| 7 | `app-dependencies` | DI 配線（live / preview / test） |
| 8 | `usecase-testing` | ユースケース記述を仕様としたテスト生成 |
| - | `ios-project-bootstrap` | xcodeproj 未作成時の初回セットアップ |


## プロジェクト構成

```
docs/
├── usecases/          # ユースケース記述（画面ごと）
│   ├── WordChallengeStartScreen/
│   ├── StudyCardScreen/
│   ├── StudyResultScreen/
│   └── ProblemListScreen/
└── domain/
    ├── cards/         # ドメインカード（Entity / VO / Repository）
    └── DomainModel.md # ドメインモデル図

Sources/App/
├── Application/       # @main App, DI
├── Domain/
│   ├── Core/          # EffectStream, RepositoryBase
│   ├── Entities/      # Word, StudySession, StudyAnswer, ...
│   ├── ValueObjects/  # SchoolGrade, StudyMode, AnswerJudgment
│   ├── Repositories/  # Repository Protocol
│   ├── UseCases/      # UseCase（AsyncStream<ViewEffect> を返す）
│   └── ViewEffects/   # 画面ごとの ViewEffect enum
├── Infrastructure/
│   └── Persistence/   # SwiftData 実装（Model / BiMapper / Repository）
└── Presentation/
    ├── Core/          # ViewProtocol
    ├── ViewStates/    # ViewState（apply で ViewEffect を処理）
    └── Views/         # SwiftUI View

Tests/
├── UseCases/          # ユースケーステスト
└── Support/           # テストヘルパー（Factory, Failing Repository）

skills/                # Claude Code スキル定義
└── _shared/           # スキル間共通規約
```
