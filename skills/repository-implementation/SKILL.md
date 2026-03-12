---
name: repository-implementation
description: |
  SwiftDataでRepository実装を作成し、EntityとPersistentModelをBiMapperで相互変換するときに使う。
---

# Repository Implementation

## 概要

このタスクで何を行うか:

- DomainのRepositoryプロトコルに対するSwiftData実装を作成する。
- EntityとPersistentModelを分離し、BiMapperで双方向変換を実装する。
- 共通CRUDは基底Repositoryに集約し、エンティティ固有クエリを追加実装する。

入力:

- `docs/domain/cards/*.md`
- `Sources/App/Domain/Entities/*.swift`
- `Sources/App/Domain/Repositories/*.swift`

参照（テンプレート・ガイドライン）:

- `skills/repository-implementation/references/*` — 実装パターンの参考
- `conventions/swiftdata-constraints.md` — SwiftData制約
- `skills/_shared/RESPONSIBILITY_BOUNDARIES.md` — 責務境界の判断基準

出力:

- `Sources/App/Infrastructure/Persistence/Core/BiMapper.swift`
- `Sources/App/Infrastructure/Persistence/Core/SwiftDataRepository.swift`
- `Sources/App/Infrastructure/Persistence/Models/<Entity>PersistentModel.swift`
- `Sources/App/Infrastructure/Persistence/Repositories/Mappers/<Entity>BiMapper.swift`
- `Sources/App/Infrastructure/Persistence/Repositories/SwiftDataRepository_<Entity>.swift`

生成後のファイル構成:

```text
Sources/App/
├── Domain/
│   ├── Entities/                    # エンティティ
│   └── Repositories/                # Repositoryプロトコル
└── Infrastructure/
    └── Persistence/
        ├── Core/                    # 共通CRUDとエラー定義を置く基盤層
        │   ├── BiMapper.swift
        │   └── SwiftDataRepository.swift
        ├── Models/                  # 永続化専用モデル（@Model）
        │   └── <Entity>PersistentModel.swift
        └── Repositories/            # Repositoryプロトコルの実装
            ├── Mappers/
            │   └── <Entity>BiMapper.swift            # Domain/Persistence相互変換
            └── SwiftDataRepository_<Entity>.swift
```

## ワークフロー

1. 入力仕様と責務境界を確認する
   - 入力: `docs/domain/cards/*.md`、`Sources/App/Domain/Entities/*.swift`、`Sources/App/Domain/Repositories/*.swift`、`skills/_shared/RESPONSIBILITY_BOUNDARIES.md`
   - 実施内容: 永続化対象エンティティ、必要CRUD/クエリ、Repository責務を確定する。
   - 実施ルール:
     - Repositoryにはビジネスロジックを入れない
     - 永続化I/OとDTO-Entity変換のみを担当する
     - ID型ルールは `conventions/swiftdata-constraints.md` に合わせる
     - Domainカードに `save(...)` が書かれていても、Repositoryプロトコルには `save` を追加しない
     - 永続化操作は `RepositoryBaseFunctionProtocol` の `insert` / `update` / `delete` に正規化する
   - 実装パターン: この手順は確認フェーズのため、コード追加は行わず対象と責務のみ確定する

2. Core基盤を配置・整備する
   - 入力: `skills/repository-implementation/references/BiMapper.swift`、`skills/repository-implementation/references/SwiftDataRepository.swift`、`Sources/App/Domain/Core/RepositoryBaseFunctionProtocol.swift`
   - 実施内容: Core基盤2ファイル（`BiMapper.swift` / `SwiftDataRepository.swift`）を `Sources/App/Infrastructure/Persistence/Core/` に配置し、既存実装との差分を最小調整する。
   - 実施ルール:
     - `RepositoryBaseFunctionProtocol` は Domain 側（`Sources/App/Domain/Core/RepositoryBaseFunctionProtocol.swift`）を参照し、Infrastructure側に同名ファイルを新規作成しない
     - `SwiftDataRepository` は `@MainActor` で定義する
     - 共通CRUD（`fetchAll` / `fetch(id:)` / `insert` / `update` / `delete`）をCoreで提供する
     - エンティティ固有クエリはCoreへ混在させない
   - 実装パターン:

     ```swift
     @MainActor
     final class SwiftDataRepository<Mapper: BiMapper> {
         typealias Domain = Mapper.Domain
         typealias Persistent = Mapper.Persistent

         private let context: ModelContext
         private let mapper: Mapper
     }
     ```

3. PersistentModelを実装する
   - 入力: `Sources/App/Domain/Entities/*.swift`、`conventions/swiftdata-constraints.md`
   - 実施内容: `Sources/App/Infrastructure/Persistence/Models/<Entity>PersistentModel.swift` を作成し、永続化用プリミティブ属性へ正規化する。
   - 実施ルール:
     - 命名は `<Entity>PersistentModel` に統一する
     - `@Model` かつ `Identifiable` に適合する
     - Value Object型を直接保持せず、`String` / `UUID` / `Int` などで保持する
   - 実装パターン:
     ```swift
     @Model
     final class TaskPersistentModel: Identifiable {
         var id: UUID
         var title: String
         var isCompleted: Bool
     }
     ```

4. BiMapperを実装する
   - 入力: `<Entity>PersistentModel.swift`、Domain Entity/ValueObject
   - 実施内容: `Sources/App/Infrastructure/Persistence/Repositories/Mappers/<Entity>BiMapper.swift` に双方向変換と更新処理を実装する。
   - 実施ルール:
     - 命名は `<Entity>BiMapper` に統一する
     - `toDomain(_:)` は `throws` とする
     - `update(persistent:from:)` でIDを変更しない
   - 実装パターン:
     ```swift
     public struct TaskBiMapper: BiMapper {
         public func toDomain(_ p: TaskPersistentModel) throws -> Task { ... }
         public func toPersistent(_ d: Task) -> TaskPersistentModel { ... }
         public func update(persistent: TaskPersistentModel, from domain: Task) { ... }
     }
     ```

5. Repository実装と固有クエリを追加する
   - 入力: `Sources/App/Domain/Repositories/*.swift`、`SwiftDataRepository.swift`、`<Entity>BiMapper.swift`
   - 実施内容: `Sources/App/Infrastructure/Persistence/Repositories/SwiftDataRepository_<Entity>.swift` を実装し、必要なクエリを拡張する。
   - 実施ルール:
     - ファイル名は `SwiftDataRepository_<Entity>.swift` に統一する
     - `typealias SwiftDataRepository_<Entity> = SwiftDataRepository<<Entity>BiMapper>` + `extension SwiftDataRepository: <Entity>Repository where Mapper == <Entity>BiMapper` で適合させる
     - 薄い委譲ラッパーや単純転送メソッドの重複実装をしない
     - `save` という別名メソッドは追加せず、作成は `insert`、更新は `update` を使い分ける
     - `update` / `delete` で対象未存在時は `RepositoryError` を返す
     - 変換失敗は `RepositoryError.conversionFailed` に正規化する
   - 実装パターン:
     ```swift
     public typealias SwiftDataRepository_Task = SwiftDataRepository<TaskBiMapper>

     extension SwiftDataRepository: TaskRepository where Mapper == TaskBiMapper {
         public func fetchCompleted() async throws -> [Task] { ... }
     }
     ```

6. 生成結果を検証する
   - 入力: 生成済みCore/Models/Mappers/Repositories、Domain Repositoryプロトコル
   - 実施内容: 命名、配置、型整合、エラー処理、責務境界の一致を確認する。
   - 実施ルール:
     - EntityとPersistentModelのID型一致を必須にする
     - Coreへビジネスロジックを入れない
     - 参考コードとの差分はプロジェクト都合の最小範囲に限定する
   - 実装パターン: この手順は確認フェーズのため、差分確認観点のみ記録する

## チェックリスト

- 概要に「このタスクで何を行うか / 入力 / 出力」が揃っている
- 出力説明に、生成後のファイル構成ツリーと役割補足がある
- すべての手順が「入力 / 実施内容 / 実施ルール / 実装パターン」で記述されている
- `<Entity>PersistentModel` が `@Model` かつ `Identifiable` に適合している
- `<Entity>BiMapper` に `toDomain` / `toPersistent` / `update` が実装されている
- `SwiftDataRepository_<Entity>.swift` がDomain Repositoryプロトコルに適合している
- `typealias + 制約付きextension` で `SwiftDataRepository<<Entity>BiMapper>` に適合している
- 単純転送メソッドを重複実装していない
- Repositoryプロトコルに `save` が追加されておらず、`insert/update/delete` に統一されている
- Repository実装にビジネスロジックを混在させていない
