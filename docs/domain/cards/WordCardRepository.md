# WordCardRepository（単語カードリポジトリ）

## 概要

単語カードの取得を担当するリポジトリ。

## 操作

- fetchByGrade(grade: SchoolGrade, count: StudyItemCount): [WordCard]
- fetchByIDs(ids: [UUID]): [WordCard]

## 関連

- [WordCard](WordCard.md)
- [SchoolGrade](SchoolGrade.md)
- [StudyItemCount](StudyItemCount.md)
