---
name: skill-creator-plus
description: |
  `skill-creator` の補助スキル。
---

# Skill Creator Plus

## 概要

`skill-creator` の基本方針を使いつつ、ローカル運用の好みを追加して
新規スキル作成・既存スキル更新を行う。

- 基本方針: `skill-creator` に従う
- 追加方針: このファイルのルールを優先して上書きする

## 構成ルール

### スキル配置

- Skill実体はトップレベルの `skills/` に置く
- 変更履歴セクションは作らない（履歴はGitで管理）

### 推奨ディレクトリ構成

```text
skills/<skill-name>/
├── SKILL.md
├── agents/
│   └── openai.yaml
└── references/        # 必要な場合のみ
```

### 最小構成

- 必須: `skills/<skill-name>/SKILL.md`
- 推奨: `skills/<skill-name>/agents/openai.yaml`
- 任意: `skills/<skill-name>/references/*`

## 記述方針（ローカル好み）

- `SKILL.md` は短く保つ（重複説明を避ける）
- 具体例は最小限にし、原則1ファイルで示す
- `references/` は必要最小限のみ置く
- 変更履歴セクションは作らない（履歴はGitで管理）

## ワークフロー

### 1. 要求を固定する（最初に決める）

- スキル名を `lowercase-hyphen` で決める
- 対象タスクを1〜3行で定義する
- トリガー条件（いつ使うか）を1〜3行で定義する
- 既存スキルで代替できるかを確認する

### 2. 構成を決定する

- 最小構成（`SKILL.md`）で足りるか判断
- 例が必要な場合のみ `references/` を作る
- 具体例は原則1ファイルに集約する
- `agents/openai.yaml` は必要な場合のみ追加する

### 3. SKILL.md を作成する

- Frontmatter は `name` と短い `description` のみにする
- `description` には詳細仕様を書かず、短いトリガー文だけを書く
- 本文は次の章立てを基本とし、各章で書く内容を固定する
- 章立て:
  - 概要
  - フォルダ構成
  - ワークフロー
  - チェックリスト

##### 概要

- 次の項目をこの順で固定して書く
  - このタスクで何を行うか
  - 入力
  - 参照（テンプレート・ガイドライン）— 必要時のみ参照するファイル群がある場合
  - 出力
- 「入力」はタスク実行時に必ず読むプロジェクトファイル
- 「参照」はスキル内テンプレートや共有ガイドラインなど、必要時のみ見るファイル
- 入出力・参照は可能な限り実ファイルパスで書く

##### フォルダ構成

- 入力と出力のフォルダ構成を下のように分かりやすく書く
- 初回時に配置する固定ファイル以外は<Entity>PersistentModel.swiftの様に抽象的に書く

```
Sources/App/
├── Domain/
│   ├── Entities/                    # エンティティ
│   └── Repositories/                # Repositoryプロトコル
└── Infrastructure/
    └── Persistence/
        ├── Core/                    # 共通基盤（通常は変更不要）
        │   ├── RepositoryBaseFunctionProtocol.swift
        │   ├── BiMapper.swift
        │   └── SwiftDataRepository.swift
        ├── Models/                  # PersistentModel
        │   └── <Entity>PersistentModel.swift
        └── Repositories/            # Repository実装
            ├── Mappers/
            │   └── <Entity>BiMapper.swift
            └── SwiftDataRepository_<Entity>.swift
```

##### ワークフロー

- 手順は実行順で `1. 2. 3.` の番号付きにする
- 各手順は次の固定フォーマットで書く
  - 入力: 参照する情報源・ファイル・前手順の成果物を列挙する
  - 実施内容: その手順で実際に行う操作を1〜2文で書く（判断と作業を分ける）
  - 実施ルール: その手順で必ず守る制約（禁止事項・命名規則・粒度）だけを書く
  - 実装パターン（省略可）: コード例を書く。内部的な中間出力のフォーマットは書かない
- 手順文だけで、第三者が同じ順序で再現できる粒度にする
- 固定ファイルを配置する必要がある場合、専用のワークフローにする

例:

````md
1. ユースケース記述から ScreenEffect / AlertEffect / ViewEffect を定義する
   - 入力: `docs/usecases/<ScreenName>/<ScreenName>.md`
   - 実施内容: UIイベントとシステム応答を読み取り、`ScreenEffect`（通常UI更新）と `AlertEffect`（アラート表示）に分割し、`ViewEffect` typealias を定義する。
   - 実施ルール:
     - ケース名は動詞開始（`show` / `hide` / `navigate` など）で統一する
     - `ScreenEffect` は `showLoading` / `hideLoading` / `navigate...` など通常UI更新を担当する
     - `AlertEffect` はエラー表示・確認アラートなどアラート系を担当する
     - `ScreenEffect` は `AppEffectConvertible` に適合させる
     - `AlertEffect` は `Equatable` / `Sendable` に適合させる
     - ユースケース記述に根拠のない Effect を追加しない
   - 実装パターン:

     ```swift
     public enum CardListScreenEffect: Equatable, Sendable {
         case showLoading
         case hideLoading
         case showEmptyState
         case navigateToCreateCard
     }

     public enum CardListAlertEffect: Equatable, Sendable {
         case showError(CardListError)
     }

     public typealias CardListViewEffect = ViewEffect<CardListScreenEffect, CardListAlertEffect>

     extension CardListScreenEffect: AppEffectConvertible {
         public func asAppEffect() -> AppEffect { .cardList(self) }
     }
     ```

2. 生成結果を網羅チェックする
   - 入力: 更新後の `ViewEffect.swift` / `ViewState.swift`、`docs/usecases/<ScreenName>/<ScreenName>.md`
   - 実施内容: 仕様と実装差分を照合し、不足と過剰を判定する。
   - 実施ルール:
     - 仕様根拠のない Effect/State を追加しない
     - 遷移系 `ScreenEffect` を ViewState 側で更新しない
     - エラーは `AlertEffect` 経由で `AlertState` へ変換する
   - 実装パターン: この手順は確認フェーズのため、コード追加は行わず確認観点のみ記述する
````

##### チェックリスト

- 完了判定をYes/Noで判定できる項目にする
- 各項目は1文で短く書く
- ワークフローと矛盾しないことを確認する

### 4. references を最小で追加する（必要時のみ）

- 置き場所は `skills/<skill-name>/references/`
- `SKILL.md` だけでは迷う箇所に限定して補助例を置く
- `SKILL.md` と同じ説明を重複して書かない

### 5. 仕上げ確認

- 長文説明・重複説明を削る
- `SKILL.md` 単体で実行手順が追えることを確認する
- `description` が短いトリガー文のままか確認する
- リポジトリ運用ルールに一致しているか確認する

## チェックリスト

- `SKILL.md` だけ読めば実行手順がわかる
- `description` は短く、トリガーとして機能する
- referencesが過剰になっていない

## 関連スキル

- `skill-creator`
