---
name: domain-cards-to-swift
description: |
  ドメインカード（Markdown）からSwiftのドメイン層実装を生成するスキル。
  `docs/domain/cards/*.md` を Source of Truth とし、`Sources/App/Domain` 配下へ
  Entity / Value Object / Enum / Repository を生成する。
---

# Domain Cards to Swift

## 概要

このタスクで何を行うか:

- `docs/domain/cards/*.md` からSwiftのドメイン層コードを生成する。
- 種別（Entity / Value Object / Enum / Repository）を判定し、対応するSwiftコードを出力する。
- 共通CRUDプロトコル（RepositoryBaseFunctionProtocol）を基盤として配置する。

入力:

- `docs/domain/cards/*.md`

参照（テンプレート・ガイドライン）:

- `skills/domain-cards-to-swift/references/*` — 実装パターンの参考
- `conventions/swiftdata-constraints.md` — SwiftData制約
- `skills/_shared/RESPONSIBILITY_BOUNDARIES.md` — 責務境界の判断基準

出力:

- `Sources/App/Domain/Core/RepositoryBaseFunctionProtocol.swift`
- `Sources/App/Domain/Entities/<Entity>.swift`
- `Sources/App/Domain/ValueObjects/<ValueObject>.swift`
- `Sources/App/Domain/ValueObjects/<Enum>.swift`
- `Sources/App/Domain/Repositories/<Repository>.swift`

生成後のファイル構成:

```text
Sources/App/Domain/
├── Core/
│   └── RepositoryBaseFunctionProtocol.swift   # 共通CRUD基底プロトコル
├── Entities/                                   # Entity
│   └── <Entity>.swift
├── ValueObjects/                               # Value Object / Enum
│   └── <ValueObject>.swift
└── Repositories/                               # Repositoryプロトコル
    └── <Repository>.swift
```

## ワークフロー

1. ドメインカードを読み込み種別判定する
   - 入力: `docs/domain/cards/*.md`
   - 実施内容: カードの種別・型名・属性・制約・列挙値・操作を抽出する。
   - 実施ルール:
     - 型名はファイル名ではなくカード見出し（`# <TypeName>`）を正とし、和名は使用しない
     - `StudySession_StudyCount.md` のような集約プレフィックス付きでも型名は `StudyCount`
   - 種別判定基準:
     - **Entity**: 概要に「エンティティ」と記載
     - **Value Object**: 概要に「値オブジェクト」と記載
     - **Enum**: 概要に「列挙型」/「enum」、または `## 列挙値` セクションあり
     - **Repository**: 名前が `Repository` で終わる、または概要に「リポジトリ」
   - 実装パターン: この手順は確認フェーズのため、コード追加は行わず種別と構造のみ確定する

2. Core基盤プロトコルを配置する（初回のみ）
   - 入力: `skills/domain-cards-to-swift/references/RepositoryBaseFunctionProtocol.swift`
   - 実施内容: `Sources/App/Domain/Core/RepositoryBaseFunctionProtocol.swift` が未存在の場合、参考コードから配置する。
   - 実施ルール:
     - 基本CRUD（`fetchAll` / `fetch(id:)` / `insert` / `delete`）を定義する
     - `associatedtype Domain: Identifiable` で対象型を抽象化する
   - 実装パターン:
     ```swift
     public protocol RepositoryBaseFunctionProtocol {
         associatedtype Domain: Identifiable
         func fetchAll() async throws -> [Domain]
         func fetch(id: Domain.ID) async throws -> Domain?
         func insert(_ domain: Domain) async throws
         func delete(id: Domain.ID) async throws
     }
     ```

3. Entityを実装する
   - 入力: Entityカード、`conventions/swiftdata-constraints.md`
   - 実施内容: `Sources/App/Domain/Entities/<Entity>.swift` を生成する。
   - 実施ルール:
     - `struct` + `Identifiable` + `Equatable` + `Sendable`
     - `typealias ID = UUID` を明示し、`id` は computed property で UUID を返す
     - 内部的には `<Entity>ID` 値オブジェクトを stored property として保持する
     - `*ID` 系の Value Object は **別ファイルとして生成しない**（Entity内の stored property のみ）
     - `init` は `private` にし、`make`（新規）/ `restore`（復元）ファクトリ経由に制限する
     - `make` の引数はプリミティブ型、戻り値は `Result<Entity, EntityError>`
     - `EntityError` はEntity側で定義し、値オブジェクトのErrorを内包する
   - 実装パターン:

     ```swift
     public struct Task: Identifiable, Equatable, Sendable {
         public typealias ID = UUID
         public var id: UUID { taskID.value }
         public let taskID: TaskID
         public let title: TaskTitle

         private init(id: TaskID, title: TaskTitle) { ... }

         public static func make(title: String) -> Result<Task, TaskError> {
             create(id: UUID(), title: title)
         }
         public static func restore(id: UUID, title: String) -> Result<Task, TaskError> {
             create(id: id, title: title)
         }
     }

     public enum TaskError: Error, Equatable, Sendable {
         case title(TaskTitleError)
     }
     ```

4. Value Objectを実装する
   - 入力: Value Objectカード
   - 実施内容: `Sources/App/Domain/ValueObjects/<ValueObject>.swift` を生成する。
   - 実施ルール:
     - `struct` + `Equatable` + `Sendable`
     - `value` プロパティで内部値を保持する
     - 制約がある場合は `throws init` とし、エラー型を同ファイルに定義する
     - `*ID` 系の Value Object は生成しない（IDは Entity の `UUID` を直接使う）
   - 実装パターン:
     ```swift
     public struct TaskTitle: Equatable, Sendable {
         public let value: String
         public init(_ value: String) throws {
             guard !value.isEmpty else { throw TaskTitleError.empty }
             self.value = value
         }
     }
     public enum TaskTitleError: Error { case empty }
     ```

5. Enumを実装する
   - 入力: Enumカード
   - 実施内容: `Sources/App/Domain/ValueObjects/<Enum>.swift` を生成する。
   - 実施ルール:
     - `enum` + `String` + `CaseIterable` + `Sendable`
     - ケースはカードの `## 列挙値` を定義元とする
     - 外部保存値が必要な場合は `rawValue` を使う
   - 実装パターン:
     ```swift
     public enum SchoolGrade: String, CaseIterable, Sendable {
         case junior1 = "中1"
         case junior2 = "中2"
     }
     ```

6. Repositoryプロトコルを実装する
   - 入力: Repositoryカード、`skills/_shared/RESPONSIBILITY_BOUNDARIES.md`
   - 実施内容: `Sources/App/Domain/Repositories/<Repository>.swift` を生成する。
   - 実施ルール:
     - `protocol` + `RepositoryBaseFunctionProtocol`
     - `typealias Domain = <Entity>` で基底CRUDの対象型を指定する
     - クエリ系メソッドは必要に応じて追加定義する（検索条件の指定のみ。結果の加工・集計は呼び出し側の責務）
     - ビジネスロジックはRepositoryに含めない（Entity やドメインサービスの責務）
     - Repositoryメソッドは CRUD 操作（`insert` / `update` / `delete` / `fetch〜`）に限定する。Entity の生成（ファクトリ呼び出し）や複数操作の組み合わせは Repository の外で行う
   - 実装パターン:
     ```swift
     public protocol TaskRepository: RepositoryBaseFunctionProtocol {
         typealias Domain = Task
         // 基本CRUD は RepositoryBaseFunctionProtocol から継承
         // クエリ系は必要に応じて追加:
         // func fetchCompleted() async throws -> [Task]
     }
     ```

7. 生成結果を検証する
   - 入力: 生成済みファイル、ドメインカード
   - 実施内容: 命名、配置、型整合、プロトコル適合を確認する。
   - 実施ルール:
     - 生成ファイルの先頭に「自動生成」コメントを付与する
     - 依存方向はDomain内で閉じる
     - すべて `public` で定義する
     - `*ID` 型を新規ファイルとして生成していないことを確認する
   - 実装パターン: この手順は確認フェーズのため、差分確認観点のみ記録する

## チェックリスト

- 概要に「このタスクで何を行うか / 入力 / 出力」が揃っている
- 出力説明に、生成後のファイル構成ツリーと役割補足がある
- すべての手順が「入力 / 実施内容 / 実施ルール / 実装パターン」で記述されている
- Entity が `struct` + `Identifiable` + `Equatable` + `Sendable` で `typealias ID = UUID` を持つ
- Entity に `make` / `restore` ファクトリメソッドが実装されている
- Value Object が `value` プロパティを持ち、制約ありなら `throws init` になっている
- Enum が `String` + `CaseIterable` + `Sendable` に適合している
- Repository が `RepositoryBaseFunctionProtocol` を継承し `typealias Domain` を指定している
- `*ID` 系 Value Object を別ファイルとして生成していない
- Repository にビジネスロジックを混在させていない
