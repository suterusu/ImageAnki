import Foundation

public extension AsyncStream {
    func collectAll() async -> [Element] {
        var elements: [Element] = []
        for await element in self {
            elements.append(element)
        }
        return elements
    }
}
