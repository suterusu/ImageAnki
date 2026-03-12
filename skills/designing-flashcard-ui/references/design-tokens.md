# Flashcard UI Design Tokens

`designing-flashcard-ui` で使う推奨カラーの参照定義。
Pencil依頼やUI実装で、まずこのトークンを優先して使う。

## Color Tokens

- `primary` (`Blue`, `#1A8FE3`): Primary actions, selected states, navigation elements
- `secondary` (`Purple`, `#6610F2`): Secondary actions, highlights, alternative buttons
- `accent` (`Orange`, `#F37933`): Call-to-action accents, notifications
- `success` (`Green`, `#28A745`): Correct answers, success indicators
- `warning` (`Yellow`, `#FFC107`): Warnings, caution messages, pending states
- `error` (`Red`, `#D11149`): Errors, incorrect answers, destructive actions
- `background` (`Off-white`, `#F7F8FA`): Main surfaces, app backgrounds
- `surface` (`White`, `#FFFFFF`): Cards, elevated surfaces
- `text_primary` (`Dark Gray`, `#212529`): Primary text on light backgrounds
- `text_secondary` (`Medium Gray`, `#495057`): Secondary text, labels
- `neutral_border` (`Light Gray`, `#DEE2E6`): Dividers, borders

## Recommended Usage Rules

- 学習中の主要操作は `primary` を使い、画面内で最も目立たせる。
- 同一画面で強調色は `accent` か `secondary` のどちらかを主に使い、混在させすぎない。
- 正誤フィードバックは `success` と `error` を固定運用し、意味を入れ替えない。
- ベース面は `background` と `surface` の2層を基本にし、可読性を保つ。
- テキストは原則 `text_primary`、補助情報のみ `text_secondary` を使う。
