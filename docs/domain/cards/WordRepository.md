# WordRepository（単語リポジトリ）

## 概要

単語問題の取得を担当するリポジトリ。

## 操作

- fetchByGrade(grade: SchoolGrade, limit: Int): [Word]
- fetchByIDs(ids: [UUID]): [Word]

## 関連

- [Word](Word.md)
- [SchoolGrade](SchoolGrade.md)
