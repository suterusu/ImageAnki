---
name: usecase-to-domain-cards
description: |
  ユースケース記述からドメインカードを作成するスキル（Swiftアプリ用）。
---

# Usecase to Domain Cards

## 概要

- ユースケース記述からドメインモデル候補を抽出し、ドメインカード（Entity / Value Object / Enum / Domain Service / Repository）を作成する
- 入力（実行単位）: `docs/usecases/<ScreenName>/<ScreenName>.md`（1画面指定で実行可能）
- 入力（抽出単位）: `docs/usecases/*/*.md`（原則として全画面を横断して抽出）
- 出力: `docs/domain/cards/*.md`、`docs/domain/DomainModel.md`

## フォルダ構成

```
docs/
├── usecases/                            # 入力
│   └── <ScreenName>/
│       └── <ScreenName>.md
└── domain/                              # 出力
    ├── DomainModel.md                   # ドメインモデル図
    └── cards/
        ├── <EntityName>.md
        ├── <EntityName>_<ValueObjectName>.md
        ├── <ValueObjectName>.md
        ├── <EntityName>_<EnumName>.md
        ├── <EnumName>.md
        ├── <ServiceName>.md
        └── <EntityName>Repository.md
```

## ワークフロー

### 1. ユースケースからドメイン候補を抽出する

- 入力: `docs/usecases/*/*.md`
- 実施内容: ユースケース記述を読み、名詞（型候補）・値（タイトル、IDなど）・動詞（create/update/deleteなど）を抽出する。
- 実施ルール:
  - すべてのユースケースファイルを横断的に読む
  - 同じ名詞が複数画面に現れる場合は統一候補として扱う
- 実装パターン: この手順は分析フェーズのため、コード追加は行わない

### 2. 候補をドメインモデルに分類する

- 入力: 手順1の抽出結果
- 実施内容: 抽出した候補を Entity / Value Object / Enum / Domain Service / Repository に分類する。
- 実施ルール:
  - Entity: 同一性（ID）を持ち、状態が時間で変わるもの
  - Value Object: 値の等価性が本質で、不変なもの。ただし `*ID` は作らない（UUID を直接使う）
  - Enum: 値候補が有限かつ固定で、追加・削除が頻繁でないもの
  - Domain Service: 複数の Entity/VO にまたがるロジック
  - Repository: エンティティの永続化・取得を担当するインターフェース
- 実装パターン: この手順は分析フェーズのため、コード追加は行わない

### 3. 集約境界を定義する

- 入力: 手順2の分類結果
- 実施内容: 集約（Aggregate）を定義し、集約ルートと内部要素を決定する。
- 実施ルール:
  - 一貫性ルール（不変条件）を同一トランザクションで守る単位を集約とする
  - 集計結果や派生データ（例: Summary）は集約外の Value Object 候補
  - 複数集約にまたがるロジックは Domain Service 候補
- 実装パターン: この手順は分析フェーズのため、コード追加は行わない

### 4. ドメインカードを作成する

- 入力: 手順2〜3の結果、`references/card_templates.md`
- 実施内容: `docs/domain/cards/` 配下にカードを Markdown で作成する。
- 実施ルール:
  - 概要は1行で本質のみ記載
  - 属性は実装に必要な最小限のみ
  - 操作は主要なもののみ（getter/setter は省略）
  - 詳細な説明・例・状態遷移図は含めない
  - Entity の識別子は `UUID` を直接使い、`*ID` カードは作らない
  - Repository の ID 引数・戻り値も `UUID` を使う
  - Repository カードにはビジネスロジックを追加しない（永続化は基本メソッドのみ、取得は必要な問い合わせ操作を記載してよい）
  - 用語はユースケース記述と統一する
  - すべてのドメインクラスに和名を必ず記載する（見出しを `# EnglishName（和名）` 形式にする）
  - ドメイン記述から、Entity / Domain Service に追加すべきビジネスロジックが見つかった場合は、該当カードの「操作」または「責務」に明記する
  - ファイル命名規則:
    - Entity: `<EntityName>.md`
    - Value Object（集約内のみ）: `<EntityName>_<ValueObjectName>.md`
    - Value Object（複数集約で共有）: `<ValueObjectName>.md`
    - Enum（集約内のみ）: `<EntityName>_<EnumName>.md`
    - Enum（複数集約で共有）: `<EnumName>.md`
    - Domain Service: `<ServiceName>.md`
    - Repository: `<EntityName>Repository.md`
  - 既存カードを改名した場合は、関連カード内の Markdown リンクを必ず追従更新する
- 実装パターン:

  **Entity カード**

  ```markdown
  # EntityName（エンティティ和名）

  ## 概要

  エンティティの簡潔な説明（1行）。

  ## 属性

  | 名前 | 型   | 説明   |
  | ---- | ---- | ------ |
  | id   | UUID | 識別子 |

  ## 関連

  - [RelatedModel](RelatedModel.md)
  ```

  **Value Object カード**

  ```markdown
  # ValueObjectName（値オブジェクト和名）

  ## 概要

  値オブジェクトの簡潔な説明（1行）。

  ## 属性

  | 名前  | 型  | 説明 |
  | ----- | --- | ---- |
  | value | 型  | 説明 |

  ## 制約

  - 制約1

  ## 関連

  - [RelatedModel](RelatedModel.md)
  ```

  **Enum カード**

  ```markdown
  # EnumName（列挙型和名）

  ## 概要

  列挙型の簡潔な説明（1行）。

  ## 列挙値

  - value1
  - value2

  ## 関連

  - [RelatedModel](RelatedModel.md)
  ```

  **Domain Service カード**

  ```markdown
  # ServiceName（サービス和名）

  ## 概要

  ドメインサービスの簡潔な説明（1行）。

  ## 責務

  サービスが担当する責務の簡潔な説明（1〜2行）。

  ## 操作

  - operation1(param: Type): Result

  ## 関連

  - [RelatedModel](RelatedModel.md)
  ```

  **Repository カード**

  ```markdown
  # RepositoryName（リポジトリ和名）

  ## 概要

  リポジトリの簡潔な説明（1行）。

  ## 操作

  - fetch(id: UUID): EntityName?
  - fetchAll(): [EntityName]
  - save(entity: EntityName): Void
  - delete(id: UUID): Void

  ## 関連

  - [RelatedModel](RelatedModel.md)
  ```

### 5. ドメインモデル図を更新する

- 入力: `docs/domain/cards/*.md`
- 実施内容: カード作成・更新後、`docs/domain/DomainModel.md` のドメインモデル図を更新する。
- 実施ルール:
  - クラスごとに主要な属性と主要操作（メソッド）を表示する
  - クラス名の横に和名も追加する
  - 関連（矢印）もあわせて反映する
  - Enum は `<<enumeration>>` を使って明示する
  - 追加・変更したもののみ反映し、既存を壊さない
  - リポジトリは記載しない
- 実装パターン: Mermaid クラス図で反映する

## チェックリスト

- すべてのユースケースファイルを読み込んだか
- Entity / Value Object / Enum / Domain Service / Repository が正しく分類されているか
- 集約境界が明示されているか
- `*ID` カードを作っていないか（UUID 直接使用）
- カードの概要は1行で簡潔か
- ファイル命名規則に従っているか
- 追加すべきビジネスロジックがある場合、Entity / Domain Service カードに反映されているか
- Repository カードがビジネスロジックを含まず、永続化は基本メソッドに限定されているか
- 関連カードのリンクが整合しているか
- `DomainModel.md` が最新か
