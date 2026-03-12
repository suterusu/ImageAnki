// BiMapper プロトコル
// 参考コード

import Foundation
import SwiftData

/// ドメインモデルとPersistentModelの双方向変換を行うMapperプロトコル
public protocol BiMapper {
    /// ドメインモデル型（Identifiableに適合）
    associatedtype Domain: Identifiable

    /// PersistentModel型（@Model, Identifiableに適合）
    associatedtype Persistent: PersistentModel & Identifiable

    /// PersistentModelからドメインモデルへ変換
    /// Value Objectの初期化でバリデーションエラーが発生する可能性があるため throws
    func toDomain(_ p: Persistent) throws -> Domain

    /// ドメインモデルからPersistentModelへ変換
    func toPersistent(_ d: Domain) -> Persistent

    /// 既存のPersistentModelをドメインモデルの値で更新
    /// - Parameters:
    ///   - persistent: 更新対象のPersistentModel
    ///   - domain: 更新元のドメインモデル
    func update(persistent: Persistent, from domain: Domain)
}