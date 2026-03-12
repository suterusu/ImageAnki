// このファイルは自動生成されています
// EffectStreamヘルパー

import Foundation

/// AsyncStreamのヘルパー
/// continuation.finish()やonTerminationの配線を自動化
public enum EffectStream {
    @MainActor
    public static func make<Effect: Sendable>(
        _ build: @MainActor @escaping (@MainActor @escaping (Effect) -> Void) async -> Void
    ) -> AsyncStream<Effect> {
        AsyncStream { continuation in
            let task = Task {
                await build { effect in
                    continuation.yield(effect)
                }
                continuation.finish()
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
