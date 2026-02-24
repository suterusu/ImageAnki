# StudySessionRepository（学習回リポジトリ）

## 概要

学習回の永続化と成績取得を担当するリポジトリ。

## 操作

- fetch(id: UUID): StudySession?
- fetchAll(): [StudySession]
- save(session: StudySession): Void
- fetchPerformanceSummaries(): [PerformanceSummary]

## 関連

- [StudySession](StudySession.md)
- [PerformanceSummary](PerformanceSummary.md)
