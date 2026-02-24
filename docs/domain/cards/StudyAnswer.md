# StudyAnswer（学習回答）

## 概要

学習セッション内で1枚のカードに対して入力された判定結果を表すエンティティ。

## 属性

| 名前 | 型 | 説明 |
| ---- | -- | ---- |
| id | UUID | 識別子 |
| cardId | UUID | 判定対象カードID |
| judgment | AnswerJudgment | 正誤判定 |
| answeredAt | Date | 判定時刻 |

## 関連

- [AnswerJudgment](AnswerJudgment.md)
- [WordCard](WordCard.md)
- [StudySession](StudySession.md)
