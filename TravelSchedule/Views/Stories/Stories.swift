import Foundation

struct Stories: Identifiable, Hashable, Sendable {
    var id = UUID()
    var previewImage: String
    var images: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Stories, rhs: Stories) -> Bool {
        lhs.id == rhs.id
    }
}
