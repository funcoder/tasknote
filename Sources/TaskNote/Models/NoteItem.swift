import Foundation

struct NoteItem: Identifiable, Equatable {
    let id: UUID
    let content: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
    }

    func withContent(_ newContent: String) -> NoteItem {
        NoteItem(id: id, content: newContent, createdAt: createdAt)
    }

    var relativeTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
