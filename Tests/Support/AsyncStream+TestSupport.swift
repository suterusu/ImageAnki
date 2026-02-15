import Foundation

extension AsyncStream {
    func collectAll() async -> [Element] {
        var values: [Element] = []
        for await element in self {
            values.append(element)
        }
        return values
    }
}
