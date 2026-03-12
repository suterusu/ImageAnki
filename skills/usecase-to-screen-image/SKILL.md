---
name: usecase-to-screen-image
description: |
  ユースケース記述のUI情報を主入力として、Pencilに画面構成の .pen 作成を依頼するスキル。
  `penScript.md` は補助情報として加えるだけにし、細かいフォーマットは固定しない。
---

# Usecase To Screen Image

## 概要

画面ごとのユースケース記述から、Pencilに渡す .pen 作成依頼を作る。
主情報は `## UI要素` / `## UI状態` / `## UIイベント`。
`penScript.md` は「味付け」の追加情報として扱う。

本プロジェクトでは、`designing-flashcard-ui` を基本適用する。

## 入力

- `docs/usecases/<ScreenName>/<ScreenName>.md`
- `docs/usecases/<ScreenName>/penScript.md`（任意・空でも可）
- `docs/usecases/<ScreenName>/viewScript.md` (空でも可)

`penScript.md` は必須入力ではなく、補助情報が必要な場合のみ利用する。
空ファイルなら無視してよい。

## 出力

- `docs/usecases/<ScreenName>/<ScreenName>.pen`
- 必要なら `penScript.md` を更新
- 必要なら `viewScript.md` を更新

## 参照

- `skills/designing-flashcard-ui/SKILL.md`

## 新規保存の標準手順（必須）

- 対象の `.pen` が未作成の場合は、Pencil編集に入る前に必ずファイルを先に作成する
- 作成時は、`version: "2.8"` と top-level `frame` を最低1つ含む最小JSONを直接書き込む
- 最小JSON作成後に Pencil でファイルを開き、以降のレイアウト編集を行う
- 新規保存時はこの手順を常に適用し、Pencilの新規保存挙動には依存しない

## 作業ルール

- 画面画像の依頼先は Pencil を使う
- まず `docs/usecases/<ScreenName>/<ScreenName>.md` のUI関連を読み、画面構成を決める
- iOS画面の生成では `designing-flashcard-ui` をデザインの参考として使う
- 画面にナビゲーションバーのタイトルなどが必要な場合、penで追加せず、内容詳細を`viewScript.md`に追記しておく
- `penScript.md` が空でなければ、雰囲気・演出・トーンの補助情報として加える
- 情報が競合した場合はユースケース記述を優先する
- Pencilへの依頼は、上記要素に加えて「iOSの画面を作成してくれ」とだけ伝えればよい
- Pencilへの依頼内容は「同一フォルダに `.pen` ファイルを作成すること」を明示する
- Pencilへの依頼内容に「画面内テキストの言語は日本語」を明示する
- 画面テキストは仮置き文言（例: テキスト、タイトル、ラベル、lorem ipsum）を禁止し、UI要素の意味が伝わる具体文言にする

## フロー1+開始前チェック（必須）

- ナビゲーションバーが必要な場合、`viewScript.md` へ以下の詳細を追記する
  - タイトル
  - タイトル表示モード（例: inline / large）
  - 戻るボタン表示方針

## Pencil実行方針

- 新規作成時は、先に最小JSONで `.pen` を作成してから Pencil で開く
- Pencil上で画面を生成し、`docs/usecases/<ScreenName>/<ScreenName>.pen` として同一フォルダに保存する
- `.pen` のルートには `version: "2.8"` を設定する（Pencil互換フォーマット）
- 必要なら差分修正を行う
- 1回で決めきれない場合は反復して調整する

## 注意事項

- このスキルは .pen 作成用。画像生成やSwift実装は行わない
- 1依頼につき1画面を基本に扱う
- 生成後は必ず次を確認する
  - ファイルが実際に作成されていること（0 byteでないこと）
  - `.pen` がJSONとして妥当であること
  - `version` が `"2.8"` であること
  - Pencilで `open_document` / `get_editor_state` により読み込めること
