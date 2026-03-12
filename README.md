# ImageAnki

中学生向けの必修英単語（中1/中2/中3）を、画像付きカード学習でテンポよく覚えられる iOS アプリ。

このリポジトリは **AI コーディングエージェントのスキル（Skills）だけで iOS アプリを構築する実験プロジェクト**でもある。ユースケース駆動設計をベースに、要求定義からコード生成・テストまでの全工程をスキルとして定義し、再現可能なパイプラインにしている。
## 画面構成

| タブ     | 画面                     | 概要                                                     |
| -------- | ------------------------ | -------------------------------------------------------- |
| 単語挑戦 | WordChallengeStartScreen | 学年・問題数を選んで学習または復習を開始する              |
| 単語挑戦 | StudySessionScreen       | カード画像を表示し、スワイプ判定と長押し切り替えで学習する |
| 成績一覧 | PerformanceListScreen    | 学習履歴の概要一覧を表示する                             |
| 成績一覧 | PerformanceDetailScreen  | 選択した学習回の正誤内訳と単語詳細を表示する             |

## 設計思想

### ユースケース駆動で仕様とコードを 1:1 にする

ユースケース記述（ユーザーとシステムのやりとりを手順で記述したもの）を全工程の Source of Truth にしている。

```
ユースケース記述 → ドメインカード → コード実装 → テスト
```

ユースケース記述の「システムは〜する」1 手順 ＝ UseCase の 1 処理ステップとなることを目指す。仕様・テスト・コードが同じ粒度で並ぶため、差分が見つけやすい。

### UseCase が ScreenEffect / AlertEffect を返す

UseCase は処理結果を直接返すのではなく、画面をどう変化させるかを ViewEffect として発行する。こうすることでユースケース記述がほぼそのまま UseCase コードに転写される。

SwiftData の `@Query` は採用していない。画面表示の変化はすべて ViewEffect を経由させることで、UseCase コードとユースケース記述の 1:1 対応を行いやすくしている。

```swift
public func startSession() async -> AsyncStream<StudySessionScreenViewEffect>
```

ViewEffect は `ViewEffect<ScreenEffect, AlertEffect>` のラッパー型で、通常 UI 更新とアラート表示を型レベルで分離する。

```swift
public enum ViewEffect<Screen, Alert> {
    case screen(Screen)   // ローディング・画面遷移・リスト更新など
    case alert(Alert)     // エラー表示・確認ダイアログなど
}
```

UseCase は `.screen(.showLoading)` や `.alert(.showError(...))` を yield するだけに徹し、各 Effect の処理先が型で決まる。

| Effect                 | 処理先    | 処理内容                          |
| ---------------------- | --------- | --------------------------------- |
| `.screen` の UI 更新系 | ViewState | `isLoading` などの状態を更新      |
| `.screen` の遷移系     | AppState  | NavigationPath を操作             |
| `.alert`               | ViewState | AlertState を生成してアラート表示 |

この分離により、UseCase は「何が起きたか」だけを発行し、「どう表示するか」（ViewState）と「どこへ遷移するか」（AppState）の判断を持たない。

| レイヤー  | 責務                                                                                       |
| --------- | ------------------------------------------------------------------------------------------ |
| UseCase   | ユースケース実行。Repository 呼び出し → ScreenEffect / AlertEffect 発行                    |
| ViewState | ScreenEffect の UI 更新系を受けて状態更新。AlertEffect → AlertState 変換。エラー文言もここ |
| AppState  | ScreenEffect の遷移系のみ処理。NavigationPath 管理                                         |
| View      | ViewState の描画と入力イベントの送信                                                       |

### ドメインカードで中間表現を挟む

ユースケース記述から直接 Swift コードを生成するのではなく、間に**ドメインカード**（Markdown 形式の Entity / Value Object / Enum / Domain Service / Repository 定義）を挟んでいる。

```
ユースケース記述 → ドメインカード(*.md) → Swift コード
```

ユースケース記述はユーザーとシステムのやりとりを記述するだけなので、それだけではアプリは完成しない。Entity の属性や制約、ビジネスロジックといった詳細はドメインカードの段階で決定する。また、複数画面にまたがるドメイン概念の整合性もコード生成前にここで確認できる。

### 画面遷移

画面遷移は `docs/ScreenFlow.md` の木構造で一元管理している。木構造にすることで任意の 2 画面間の遷移ルートが常に 1 つだけになり、同じ画面へ複数の経路が生まれることを構造的に防いでいる。

```
Root(Tab)
├── 単語挑戦タブ
│   └── WordChallengeStartScreen
│       └── StudySessionScreen
└── 成績一覧タブ
    └── PerformanceListScreen
        └── PerformanceDetailScreen
```

遷移操作は 2 種類だけに限定している。

| 操作               | 意味                                             | 例                                             |
| ------------------ | ------------------------------------------------ | ---------------------------------------------- |
| `popToRoot → push` | ツリーのパスに沿ってスタックを巻き戻してから遷移 | WordChallengeStartScreen → StudySessionScreen   |
| `switchTab`        | タブを切り替える                                 | 単語挑戦タブ → 成績一覧タブ                    |

この設計には以下の狙いがある。

- **ツリーだから任意の 2 画面間のパスが 1 つだけ存在する**。push / pop / popToRoot などの具体的なナビゲーション操作は木構造から一意に導出できるため、ユースケース記述では「システムは〜画面へ遷移する」とだけ書けばよい。
- **NavigationStack は RootView で 1 つだけ**。AppState が `NavigationPath` と `selectedTab` のみを保持し、ScreenEffect の遷移系ケースだけを処理する。ネストした NavigationStack は使わない。
- **ユースケース記述に遷移操作を書かない**。push / pop / switchTab はコード側が木構造から判断するため、仕様記述と実装詳細が分離される。

## スキルパイプライン

全 16 スキルが 2 つのフローとユーティリティに分かれている。

### フロー 1: 要求 → ドキュメント

| 順序 | スキル                          | やること                                                   |
| ---- | ------------------------------- | ---------------------------------------------------------- |
| 1    | `usecase-description-authoring` | 画面ごとのユースケース記述を作成                           |
| 2    | `usecase-to-domain-cards`       | ユースケースからドメインカードを抽出                       |
| 1+   | `usecase-to-screen-image`       | ユースケースの UI 情報から `.pen` 画面モックを作成（任意） |

### フロー 2: ドキュメント → コード

| 順序 | スキル                              | やること                                                                     |
| ---- | ----------------------------------- | ---------------------------------------------------------------------------- |
| 1    | `domain-cards-to-swift`             | ドメインカードから Entity / Value Object / Enum / Repository Protocol を生成 |
| 2    | `usecase-to-view-effects-and-state` | ScreenEffect / AlertEffect / ViewEffect と ViewState を定義                  |
| 2    | `error-implementation`              | 各レイヤーのエラー型を定義                                                   |
| 3    | `usecase-implementation`            | UseCase の実装（Protocol + Struct + Unimplemented）                          |
| 4    | `repository-implementation`         | SwiftData による Repository 実装と BiMapper                                  |
| 5    | `swiftui-view-implementation`       | SwiftUI View の実装                                                          |
| 6    | `app-state-implementation`          | AppState（画面遷移管理）の実装                                               |
| 6    | `root-view`                         | RootView と NavigationStack の構成                                           |
| 7    | `app-dependencies`                  | DI 配線（live / preview / test）                                             |
| 8    | `usecase-testing`                   | ユースケース記述を仕様としたテスト生成                                       |

### ユーティリティ

| スキル                  | やること                             |
| ----------------------- | ------------------------------------ |
| `ios-project-bootstrap` | xcodeproj 未作成時の初回セットアップ |

## ドメインモデル

```
WordCard（単語カード）
├── SchoolGrade（学年: 中1 / 中2 / 中3）
├── PromptText / MeaningText / ImagePNGName

StudySession（学習回）
├── StudyAnswer（解答）[] ─→ WordCard
├── StudyMode（学習モード: 学習 / 復習）
├── SchoolGrade?（学年フィルタ）
├── StudyItemCount（出題数）
└── StudySessionStatus（状態: 進行中 / 完了）

PerformanceSummary（成績サマリ）─→ StudySession
AnswerJudgment（判定: 正解 / 不正解）

ReviewSelectionService（復習カード選定サービス）
```

詳細は `docs/domain/DomainModel.md` を参照。

## プロジェクト構成

```
docs/
├── ScreenFlow.md              # ナビゲーションツリー
├── usecases/                  # ユースケース記述（画面ごと）
│   ├── WordChallengeStartScreen/
│   ├── StudySessionScreen/
│   ├── PerformanceListScreen/
│   └── PerformanceDetailScreen/
└── domain/
    ├── DomainModel.md         # ドメインモデル図（Mermaid）
    └── cards/                 # ドメインカード（Entity / VO / Enum / Service / Repository）

Sources/App/
├── Application/               # @main App, DI
├── Domain/
│   ├── Core/                  # EffectStream, ViewEffect, RepositoryBase
│   ├── Entities/              # WordCard, StudySession, StudyAnswer
│   ├── ValueObjects/          # SchoolGrade, StudyMode, AnswerJudgment, StudySessionStatus,
│   │                          #   StudyItemCount, PerformanceSummary,
│   │                          #   WordCard_PromptText, WordCard_MeaningText, WordCard_ImagePNGName
│   ├── Repositories/          # Repository Protocol, RepositoryError, ReviewSelectionService
│   ├── UseCases/              # UseCase（AsyncStream<ViewEffect> を返す）
│   └── ViewEffects/           # 画面ごとの ScreenEffect / AlertEffect / ViewEffect
├── Infrastructure/
│   └── Persistence/           # SwiftData 実装
│       ├── Core/              # BiMapper, SwiftDataRepository
│       ├── Models/            # PersistentModel（@Model）
│       └── Repositories/      # Repository 実装 + BiMapper
└── Presentation/
    ├── Core/                  # ViewStateProtocol, EffectHandlingView, AlertState
    ├── ViewStates/            # ViewState（apply で ViewEffect を処理）
    └── Views/                 # SwiftUI View

Tests/
├── UseCases/                  # ユースケーステスト
└── Support/                   # テストヘルパー（Factory, Failing Repository）
```
