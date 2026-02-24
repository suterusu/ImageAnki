# ReviewSelectionService（復習選定サービス）

## 概要

誤答履歴と経過時間を使って復習優先度の高いカードを選定するドメインサービス。

## 責務

過去の学習回答から復習候補を算出し、指定件数ぶんの出題カードIDを優先順で返す。

## 操作

- selectReviewCardIDs(sessions: [StudySession], targetCount: StudyItemCount, now: Date): [UUID]

## 関連

- [StudySession](StudySession.md)
- [StudyAnswer](StudyAnswer.md)
- [StudyItemCount](StudyItemCount.md)
- [WordCard](WordCard.md)
