# StudyAnswer（学習判定）

## 概要

1問の正誤判定を表すエンティティ。

## 属性

| 名前 | 型 | 説明 |
| ---- | -- | ---- |
| id | UUID | 判定の識別子 |
| wordID | UUID | 対象単語ID |
| judgment | AnswerJudgment | 正誤判定 |
| answeredAt | Date | 判定日時 |

## 関連

- [AnswerJudgment](AnswerJudgment.md)
- [Word](Word.md)
- [StudySession](StudySession.md)
