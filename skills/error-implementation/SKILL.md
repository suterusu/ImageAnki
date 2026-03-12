---
name: error-implementation
description: |
  アプリケーション全体のエラー型定義を実装するスキル（Swiftアプリ用）。
  Infrastructure層からUseCase層まで、層ごとのエラー型を定義する。

  エラーの層構造:
  - Infrastructure層: SwiftDataなどのSDKのErrorをそのまま使用
  - Domain層: Value Objectのエラー（TaskTitleErrorなど）
  - Repository層: RepositoryError（innerErrorのみ、CRUDに集中）
  - UseCase層: 各画面ごとのError（TaskListError、CreateTaskErrorなど）

  重要な設計方針:
  - エラーは使用する場所と同じファイルに定義（凝集度を高める）
  - UseCaseErrorは単純なEnum（メッセージプロパティなし）
  - AlertEffectでUseCaseErrorを渡し、ViewStateがAlertStateへ変換
---

# Error Implementation

## 概要

各層で発生するエラーを型安全に扱い、上位層で適切にハンドリングできるようにする。
エラー型の定義に集中するスキル。ハンドリング方法は `usecase-implementation` スキルを参照。

- エラーは使用する場所と同じファイルに定義（凝集度を高める）
- エラー文言の最終決定はViewState側の責務
- 責務境界の詳細: `skills/_shared/RESPONSIBILITY_BOUNDARIES.md`

## エラーの層構造

### 1. Infrastructure層

SwiftDataなどのSDKの `Error` をそのまま使用。独自のエラー型は作らない。

### 2. Domain層

Value Objectのバリデーションエラーを、Value Objectと同じファイルに定義:

```swift
// TaskTitle.swift
public struct TaskTitle: Equatable, Sendable {
    public let value: String

    public init(_ value: String) throws {
        guard !value.isEmpty else { throw TaskTitleError.empty }
        guard value.count <= 100 else { throw TaskTitleError.tooLong }
        self.value = value
    }
}

public enum TaskTitleError: Error, Sendable {
    case empty
    case tooLong
}
```

### 3. Repository層（RepositoryError）

`Sources/App/Domain/Repositories/RepositoryError.swift` に共通エラーを定義。
Repositoryプロトコルと同じDomain層に配置する。

```swift
public enum RepositoryError: Error, Sendable {
    case innerError(Error)
    case updateTargetNotFound
    case deleteTargetNotFound
    case conversionFailed(Error)
}

extension RepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .innerError(let error):
            return "永続化層でエラーが発生しました: \(error.localizedDescription)"
        case .updateTargetNotFound:
            return "更新対象が見つかりませんでした。"
        case .deleteTargetNotFound:
            return "削除対象が見つかりませんでした。"
        case .conversionFailed(let error):
            return "データの変換に失敗しました: \(error.localizedDescription)"
        }
    }
}
```

### 4. UseCase層（UseCaseError）

各画面ごとに専用のエラー型を、UseCaseと同じファイルに定義する。
ユースケース記述の例外フローからエラーケースを抽出し、2種類に分類する:

**解釈可能なエラー（独自ケース）** — ユースケース記述で説明できるもの:

```swift
case taskNotFound         // Repository層のnilを「見つからない」に解釈
case emptyTitle           // Domain層のTaskTitleError.emptyを解釈
case titleTooLong         // Domain層のTaskTitleError.tooLongを解釈
```

**解釈困難なエラー（associated valueなし）** — 技術的詳細に依存するもの:

```swift
case fetchFailed            // 原因は保持しない
case updateFailed
case deleteFailed
```

**UseCaseErrorにErrorやRepositoryErrorをassociated valueとして持たせない。**
- `Sendable` 準拠を壊さない（`any Error` は `Sendable` 非準拠）
- UseCase層は「何が失敗したか」だけを表現し、原因の詳細は関知しない
- デバッグが必要な場合はRepository層以下でログを出す（UseCaseの責務外）

```swift
// TaskListUseCase.swift に定義
public enum TaskListError: Error, Sendable {
    case taskNotFound
    case fetchFailed
    case updateFailed
    case deleteFailed
}
```

```swift
// CreateTaskUseCase.swift に定義
public enum CreateTaskError: Error, Sendable {
    case emptyTitle
    case titleTooLong
    case createFailed
}
```

## ファイル配置

```
Sources/App/
├── Domain/
│   ├── ValueObjects/
│   │   └── TaskTitle.swift              # TaskTitle + TaskTitleError
│   ├── Repositories/
│   │   ├── TaskRepository.swift         # Repositoryプロトコル
│   │   └── RepositoryError.swift        # RepositoryError（共通）
│   └── UseCases/
│       ├── TaskListUseCase.swift        # TaskListUseCase + TaskListError
│       └── CreateTaskUseCase.swift      # CreateTaskUseCase + CreateTaskError
└── Infrastructure/
    └── Persistence/
        └── Repositories/
            └── SwiftDataRepository_Task.swift
```

## 命名規則

| 層         | enum名                                         | 配置                                        |
| ---------- | ---------------------------------------------- | ------------------------------------------- |
| Domain     | `<ValueObject名>Error`（例: `TaskTitleError`） | Value Objectと同じファイル                  |
| Repository | `RepositoryError`                              | `Domain/Repositories/RepositoryError.swift` |
| UseCase    | `<ScreenName>Error`（例: `TaskListError`）     | UseCaseと同じファイル                       |

- プロトコル適合: `Error` + `Sendable`
- ケース命名: 動詞+Failed形式（`fetchFailed`）、説明的な名前（`emptyTitle`）

## 設計判断

### なぜ下層のエラー型に依存しないのか

```swift
// ❌ 下層の型に依存
case titleError(TaskTitleError)
case fetchFailed(RepositoryError)

// ✅ 独自ケースのみ（associated valueなし）
case emptyTitle                  // 解釈して独自ケースに変換
case fetchFailed                 // 原因は保持しない
```

- UseCaseの独立性を保つ（Value ObjectやRepositoryの変更に影響されない）
- 同じエラーでもUseCaseによって異なる意味を持つ（例: Repository nilが「エラー」か「空リスト」かはUseCaseの文脈次第）
- `Sendable` 準拠を保証する（`any Error` は `Sendable` 非準拠のため持たせない）

## 関連スキル

- `usecase-implementation`: UseCaseでのエラーハンドリングとAlertEffect発行
- `usecase-to-view-effects-and-state`: ScreenEffect / AlertEffect の定義とViewState実装
- `swiftui-view-implementation`: ViewでのbindAlertとAlertState表示
