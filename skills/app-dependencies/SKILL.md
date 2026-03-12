---
name: app-dependencies
description: |
  AppDependencies（DI設定）を生成するスキル（Swiftアプリ用）。
  SwiftUI EnvironmentValuesベースのDIで、Environment別（live/preview/test）に依存を組み立てる。
---

# App Dependencies

## 概要

このタスクで何を行うか:

- アプリ全体のDI（依存性注入）を管理する `AppDependencies` struct を生成する。
- SwiftUI の `EnvironmentValues` + `@Entry` で外部パッケージに依存しないDI構成を実現する。
- Environment別（live/preview/test）でModelContainerを切り替える。

入力:

- `Sources/App/Domain/UseCases/*UseCaseProtocol` 一覧
- `Sources/App/Domain/Repositories/*Repository` 一覧
- `Sources/App/Infrastructure/Persistence/Models/*PersistentModel` 一覧

参照（テンプレート・ガイドライン）:

- `skills/app-dependencies/references/AppDependencies_example.swift` — 実装パターンの参考
- `skills/_shared/RESPONSIBILITY_BOUNDARIES.md` — 責務境界の判断基準

出力:

- `Sources/App/Application/App/AppDependencies.swift`（AppDependencies + EnvironmentValues拡張 + テスト用アクセサ）
- `Sources/App/Application/App/<AppName>App.swift` の更新

生成後のファイル構成:

```text
Sources/App/Application/App/
├── <AppName>App.swift          # @main App struct（DI注入）
└── AppDependencies.swift       # AppDependencies + EnvironmentValues拡張
```

## ワークフロー

1. 依存対象を確認する
   - 入力: UseCaseProtocol一覧、Repository一覧、PersistentModel一覧
   - 実施内容: DI対象のUseCase・Repository・PersistentModelを確定する。
   - 実装パターン: この手順は確認フェーズのため、コード追加は行わず対象のみ確定する

2. AppDependencies.swift を生成する
   - 入力: 手順1の対象一覧、`skills/app-dependencies/references/AppDependencies_example.swift`
   - 実施内容: `AppDependencies` struct、`EnvironmentValues` 拡張、テスト用アクセサを1ファイルに生成する。
   - 実施ルール:
     - `make(for:)` 内の組み立て順序: ModelContainer → Repository → UseCase
     - live: 実ファイルModelContainer、preview/test: in-memory ModelContainer
     - `@Entry` のデフォルト値は Unimplemented版（`usecase-implementation` スキルで生成）
     - テスト用アクセサは `assert(environment == .test)` ガード付き
     - Repositoryは `fileprivate` にしUseCase以外からアクセス禁止にする
     - UseCaseは `any <ScreenName>UseCaseProtocol` で保持する
   - 実装パターン:

     ```swift
     @MainActor
     public struct AppDependencies {
         public enum Environment { case live, preview, test }

         let environment: Environment
         public let modelContainer: ModelContainer
         public let taskListUseCase: any TaskListUseCaseProtocol
         fileprivate let taskRepository: any TaskRepository

         static func make(for environment: Environment) -> AppDependencies {
             do {
                 let modelContainer = try {
                     switch environment {
                     case .live:
                         try ModelContainer(for: TaskPersistentModel.self)
                     case .preview, .test:
                         try ModelContainer(for: TaskPersistentModel.self,
                             configurations: ModelConfiguration(isStoredInMemoryOnly: true))
                     }
                 }()
                 let repository = SwiftDataRepository<TaskBiMapper>(
                     context: modelContainer.mainContext, mapper: TaskBiMapper())
                 return AppDependencies(environment: environment,
                     modelContainer: modelContainer,
                     taskListUseCase: TaskListUseCase(taskRepository: repository),
                     taskRepository: repository)
             } catch { fatalError("Failed to build AppDependencies: \(error)") }
         }
     }

     extension AppDependencies {
         var taskRepositoryForTest: any TaskRepository {
             assert(environment == .test)
             return taskRepository
         }
     }

     extension EnvironmentValues {
         @Entry var taskListUseCase: any TaskListUseCaseProtocol = UnimplementedTaskListUseCase()
     }
     ```

3. App struct を更新する
   - 入力: `Sources/App/Application/App/<AppName>App.swift`
   - 実施内容: `.environment()` と `.modelContainer()` でDIを注入する。
   - 実施ルール:
     - UseCaseは `.environment(\.key, value)` で注入する
     - ModelContainerは `.modelContainer(container)` で注入する
   - 実装パターン:
     ```swift
     @main
     struct MyApp: App {
         private let di = AppDependencies.make(for: .live)
         var body: some Scene {
             WindowGroup {
                 RootView()
                     .environment(\.taskListUseCase, di.taskListUseCase)
                     .modelContainer(di.modelContainer)
             }
         }
     }
     ```

4. 生成結果を検証する
   - 入力: 生成済みファイル、UseCaseProtocol一覧
   - 実施内容: 全UseCaseの注入漏れ、組み立て順序、テスト用アクセサの整合を確認する。
   - 実施ルール:
     - `make(for:)` の順序が ModelContainer → Repository → UseCase になっている
     - 全UseCaseが `EnvironmentValues` に `@Entry` 登録されている
     - Repositoryが `fileprivate` になっている
   - 実装パターン: この手順は確認フェーズのため、差分確認観点のみ記録する

## チェックリスト

- `make(for:)` の順序が ModelContainer → Repository → UseCase になっている
- live は実ファイル、preview/test は in-memory の ModelContainer になっている
- Repository が `fileprivate` で UseCase 以外からアクセスできない
- 全 UseCase が `EnvironmentValues` に `@Entry` 登録されている
- `@Entry` のデフォルト値が Unimplemented版になっている
- テスト用アクセサに `assert(environment == .test)` がある
- App struct で `.environment()` と `.modelContainer()` による注入がある
