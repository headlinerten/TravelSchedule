import Foundation

// MARK: - Legacy Models (сохраняем для MockDataStore)
struct Station: Identifiable, Hashable, Sendable {
    let id = UUID()
    let name: String
}

struct City: Identifiable, Hashable, Sendable {
    let id = UUID()
    let name: String
    let stations: [Station]
}
