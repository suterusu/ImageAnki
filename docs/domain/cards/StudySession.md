# StudySession（学習回）

## 概要

学習または復習の1回分を管理し、進捗と結果を保持するエンティティ。

## 属性

| 名前 | 型 | 説明 |
| ---- | -- | ---- |
| id | UUID | 識別子 |
| startedAt | Date | 開始日時 |
| mode | StudyMode | 学習モード |
| gradeFilter | SchoolGrade? | 学習モード時の対象学年 |
| targetCount | StudyItemCount | 学習予定件数 |
| status | StudySessionStatus | 進行状態 |
| answers | [StudyAnswer] | 判定結果一覧 |

## 操作

- recordAnswer(cardId: UUID, judgment: AnswerJudgment, answeredAt: Date): Void
- completeIfFinished(): Bool
- correctCount(): Int
- incorrectCount(): Int

## 関連

- [StudyMode](StudyMode.md)
- [SchoolGrade](SchoolGrade.md)
- [StudyItemCount](StudyItemCount.md)
- [StudySessionStatus](StudySessionStatus.md)
- [StudyAnswer](StudyAnswer.md)
- [PerformanceSummary](PerformanceSummary.md)
- [StudySessionRepository](StudySessionRepository.md)
