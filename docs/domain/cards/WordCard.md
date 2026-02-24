# WordCard（単語カード）

## 概要

学習で提示する1枚分の問題カードを表すエンティティ。

## 属性

| 名前 | 型 | 説明 |
| ---- | -- | ---- |
| id | UUID | 識別子 |
| grade | SchoolGrade | 学年区分 |
| promptText | PromptText | 問題表示内容 |
| meaningText | MeaningText | 意味表示内容 |
| imagePNGName | ImagePNGName | 画像ファイル名 |

## 関連

- [SchoolGrade](SchoolGrade.md)
- [PromptText](WordCard_PromptText.md)
- [MeaningText](WordCard_MeaningText.md)
- [ImagePNGName](WordCard_ImagePNGName.md)
- [StudyAnswer](StudyAnswer.md)
- [WordCardRepository](WordCardRepository.md)
