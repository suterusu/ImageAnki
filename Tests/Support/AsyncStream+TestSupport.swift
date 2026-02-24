import Foundation
import ImageAnki

extension AsyncStream {
    func collectAll() async -> [Element] {
        var values: [Element] = []
        for await value in self {
            values.append(value)
        }
        return values
    }
}
