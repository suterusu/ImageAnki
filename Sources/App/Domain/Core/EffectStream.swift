// 自動生成
import Foundation

public enum EffectStream {
    @MainActor
    public static func make<Effect: Sendable>(
        _ build: @MainActor @escaping (@MainActor @escaping (Effect) -> Void) async -> Void
    ) -> AsyncStream<Effect> {
        AsyncStream { continuation in
            Task { @MainActor in
                await build { effect in
                    continuation.yield(effect)
                }
                continuation.finish()
            }
        }
    }
}
