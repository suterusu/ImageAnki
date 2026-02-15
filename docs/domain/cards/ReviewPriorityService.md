# ReviewPriorityService（復習優先度サービス）

## 概要

誤答履歴から復習問題の優先順を決定するドメインサービス。

## 責務

学習履歴と判定結果を集計して復習対象を優先度順で抽出する。

## 操作

- selectReviewWords(sessions: [StudySession], limit: Int): [Word]

## 関連

- [StudySession](StudySession.md)
- [StudyAnswer](StudyAnswer.md)
- [Word](Word.md)
