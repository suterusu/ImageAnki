# PerformanceSummary（成績概要）

## 概要

成績一覧セルへ表示する学習回の要約情報を表す値オブジェクト。

## 属性

| 名前 | 型 | 説明 |
| ---- | -- | ---- |
| sessionId | UUID | 学習回ID |
| studiedAt | Date | 学習日時 |
| gradeLabel | String | 学年表示文字列 |
| correctCount | Int | 正解数 |
| incorrectCount | Int | 不正解数 |

## 制約

- correctCountは0以上とする
- incorrectCountは0以上とする

## 関連

- [StudySession](StudySession.md)
