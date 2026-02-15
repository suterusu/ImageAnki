// このファイルは自動生成されています

import Foundation

public enum EffectStream {
    @MainActor
    public static func make<Effect: Sendable>(
        _ build: @Sendable @escaping (@Sendable @escaping (Effect) -> Void) async -> Void
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
