---
name: ios-project-bootstrap
description: |
  iOSアプリ初期化時に、xcodeproj が未作成の状態から最小構成でプロジェクトを起動可能にするスキル。
  通常は xcodeproj 直管理を前提とし、初回のみ一時的に XcodeGen で xcodeproj を生成して、
  生成後は project.yml を削除する運用を行う。
---

# iOS Project Bootstrap

## 概要

`*.xcodeproj` が存在しないリポジトリで、初回のみ `xcodeproj` を生成してビルド可能状態にする。

## 使うタイミング

- `xcodebuild -list` が「project/workspace/package がない」エラーになる
- GUIでXcode新規作成ができない環境で、CLIだけでブートストラップしたい

## 運用原則

- 通常運用は `xcodeproj` 直管理
- `XcodeGen` は初回ブートストラップ時のみ使用
- 生成完了後は `project.yml` を削除し、再生成を前提にしない
- 生成時は `docs` を Xcode ナビゲータから参照できる状態を基本とする

## 手順

1. 既存プロジェクト確認
   - `find . -maxdepth 3 -name '*.xcodeproj' -o -name '*.xcworkspace'`
2. `xcodeproj` が無い場合のみ、一時的に `project.yml` を作成
   - アプリターゲット（`Sources/App`）とテストターゲット（`Tests`）を必ず含める
   - `fileGroups` に `docs` を含めてXcodeナビゲータから参照できるようにする
   - アプリ・テスト双方のターゲットで `GENERATE_INFOPLIST_FILE` を `YES` にする
   - アプリターゲットで `GENERATE_LAUNCH_SCREEN_FILE` を `YES` にする
3. `xcodegen generate` を実行して `*.xcodeproj` を生成
4. Xcode ナビゲータに `docs` が表示されることを確認
   - `rg -n 'path = docs;|name = docs;' <App>.xcodeproj/project.pbxproj`
5. `project.yml` を削除
6. `xcodebuild -project <App>.xcodeproj -list` を実行
7. `xcodebuild -project <App>.xcodeproj -scheme <Scheme> -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build` を実行

## 生成後チェック（推奨）

- UseCase実装ファイルが存在することを確認
  - `rg --files Sources/App | rg 'UseCase|UseCases'`
- テストターゲットが存在することを確認
  - `xcodebuild -project <App>.xcodeproj -list`
  - `project.pbxproj` に unit test bundle があることを確認
    - `rg -n 'com.apple.product-type.bundle.unit-test|Tests' <App>.xcodeproj/project.pbxproj`
- テストを組み込んでいる場合は実行
  - `xcodebuild -project <App>.xcodeproj -scheme <Scheme> -destination 'platform=iOS Simulator,name=iPhone 16' test`

### GENERATE_INFOPLIST_FILE チェック（必須）

`xcodebuild build` または `xcodebuild test` 時に以下エラーが出る場合がある:
- `Cannot code sign because the target does not have an Info.plist file ...`

アプリ・テスト双方のターゲットで `GENERATE_INFOPLIST_FILE = YES` が設定されていることを確認する。

確認コマンド:
- `rg -n 'GENERATE_INFOPLIST_FILE' <App>.xcodeproj/project.pbxproj`


## docs表示の最小要件

`project.yml` 作成時は、少なくとも `docs` ルートを `fileGroups` に含める。

- 推奨最小: `fileGroups: [docs]`
- 必要に応じて詳細化:
  - `docs/usecases`
  - `docs/domain/cards`

## 注意事項

- `project.yml` は運用ファイルとして残さない
- 再度ブートストラップが必要な場合も、同じく一時作成して生成後に削除する
- sandbox 環境で `DerivedData` 書き込み制限により `xcodebuild` が失敗する場合は、エスカレーション実行で再試行する
