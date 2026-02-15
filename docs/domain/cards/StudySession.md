# StudySession（学習回）

## 概要

1回の学習実行と判定結果を表すエンティティ。

## 属性

| 名前 | 型 | 説明 |
| ---- | -- | ---- |
| id | UUID | 学習回の識別子 |
| mode | StudyMode | 学習モード |
| grade | SchoolGrade? | 通常学習時の学年 |
| requestedCount | Int | 要求学習数 |
| startedAt | Date | 開始日時 |
| finishedAt | Date? | 終了日時 |
| answers | [StudyAnswer] | 判定結果一覧 |

## 操作

- recordAnswer(answer: StudyAnswer): Void
- finalize(): Void
- summary(): StudySessionSummary

## 関連

- [StudyMode](StudyMode.md)
- [SchoolGrade](SchoolGrade.md)
- [StudyAnswer](StudyAnswer.md)
- [StudySessionSummary](StudySessionSummary.md)
