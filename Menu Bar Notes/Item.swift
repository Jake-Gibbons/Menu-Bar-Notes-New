import Foundation
import SwiftData

@Model
final class Item: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var attributedContent: Data

    var plainText: String {
        (try? NSAttributedString(data: attributedContent, options: [:], documentAttributes: nil))?.string ?? ""
    }

    init(id: UUID = UUID(), timestamp: Date, attributedContent: Data) {
        self.id = id
        self.timestamp = timestamp
        self.attributedContent = attributedContent
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
