// 自動生成
import Foundation

public enum RepositoryError: Error, Sendable {
    case innerError(Error)
    case updateTargetNotFound
    case deleteTargetNotFound
    case conversionFailed(Error)
}
