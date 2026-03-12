// Enum 実装例
// Generated from domain card: SchoolGrade.md
// このファイルは自動生成されています

import Foundation

// MARK: - Enum: SchoolGrade

// enum + String + CaseIterable + Sendable
public enum SchoolGrade: String, CaseIterable, Sendable {
    case junior1 = "中1"
    case junior2 = "中2"
    case junior3 = "中3"
}

// MARK: - ポイント

// 1. enum で定義（有限の値集合）
// 2. String rawValue で永続化・外部連携しやすくする
// 3. CaseIterable で一覧取得可能にする
// 4. Sendable で並行処理安全性を担保する
