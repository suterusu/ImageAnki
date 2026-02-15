# StudySessionRepository（学習回リポジトリ）

## 概要

学習回の保存と取得を担当するリポジトリ。

## 操作

- fetch(id: UUID): StudySession?
- fetchAll(): [StudySession]
- save(session: StudySession): Void
- delete(id: UUID): Void

## 関連

- [StudySession](StudySession.md)
- [StudyAnswer](StudyAnswer.md)
