import Foundation

struct TaskItem: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isCompleted: Bool
    let isToday: Bool
    let createdAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        isCompleted: Bool = false,
        isToday: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
        self.isToday = isToday
        self.createdAt = createdAt
    }

    func withText(_ newText: String) -> TaskItem {
        TaskItem(id: id, text: newText, isCompleted: isCompleted, isToday: isToday, createdAt: createdAt)
    }

    func withCompleted(_ completed: Bool) -> TaskItem {
        TaskItem(id: id, text: text, isCompleted: completed, isToday: isToday, createdAt: createdAt)
    }

    func withToday(_ today: Bool) -> TaskItem {
        TaskItem(id: id, text: text, isCompleted: isCompleted, isToday: today, createdAt: createdAt)
    }

    func toggled() -> TaskItem {
        withCompleted(!isCompleted)
    }

    func toggledToday() -> TaskItem {
        withToday(!isToday)
    }
}
