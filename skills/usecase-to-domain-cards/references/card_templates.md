# ドメインカード 具体例集

SKILL.md のテンプレートだけでは迷う場合の補助例。

---

## Entity 例: Task

# Task（タスク）

## 概要

タスクを表すエンティティ。

## 属性

| 名前 | 型 | 説明 |
| ---- | -- | ---- |
| id   | UUID | 識別子 |
| title | TaskTitle | タスクタイトル |
| isCompleted | Bool | 完了状態 |

## 関連

- [TaskTitle](Task_TaskTitle.md)
- [TaskRepository](TaskRepository.md)

---

## Value Object 例: TaskTitle

# TaskTitle（タスクタイトル）

## 概要

タスクのタイトルを表す値オブジェクト。

## 属性

| 名前 | 型 | 説明 |
| ---- | -- | ---- |
| value | String | タイトル文字列 |

## 制約

- 空文字列は許可しない

## 関連

- [Task](Task.md)

---

## Enum 例: SchoolGrade

# SchoolGrade（学年）

## 概要

単語の学年区分を表す列挙型。

## 列挙値

- 中1
- 中2
- 中3

## 関連

- [Word](Word.md)

---

## Domain Service 例: TaskValidationService

# TaskValidationService（タスクバリデーションサービス）

## 概要

タスクのバリデーションを担当するドメインサービス。

## 責務

タスクの属性に対するバリデーションルールを集約する。

## 操作

- validateTitle(title: String): Result<TaskTitle, ValidationError>

## 関連

- [Task](Task.md)
- [TaskTitle](Task_TaskTitle.md)

---

## Repository 例: TaskRepository

# TaskRepository（タスクリポジトリ）

## 概要

タスクの永続化・取得を担当するリポジトリ。

## 操作

- fetchAll(): [Task]
- create(title: TaskTitle): Task
- update(id: UUID, title: TaskTitle): Task
- delete(id: UUID): Void

## 関連

- [Task](Task.md)
