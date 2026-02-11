import Foundation
import Combine

final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []

    private let fileURL: URL
    private var fileWatcher: FileWatcher?
    private var suppressNextReload = false

    init(directory: URL) {
        self.fileURL = directory.appendingPathComponent("tasks.md")
        ensureDirectoryExists(directory)
        load()
        startWatching()
    }

    func load() {
        let content = MarkdownParser.readFile(at: fileURL)
        tasks = MarkdownParser.parseTasks(from: content)
    }

    func addTask(_ text: String, isToday: Bool = false) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newTask = TaskItem(text: trimmed, isToday: isToday)
        tasks = [newTask] + tasks
        save()
    }

    func updateTask(_ task: TaskItem, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        tasks = tasks.map { item in
            item.id == task.id ? item.withText(trimmed) : item
        }
        save()
    }

    func toggleToday(_ task: TaskItem) {
        tasks = tasks.map { item in
            item.id == task.id ? item.toggledToday() : item
        }
        save()
    }

    func toggleTask(_ task: TaskItem) {
        tasks = tasks.map { item in
            item.id == task.id ? item.toggled() : item
        }
        save()
    }

    func deleteTask(_ task: TaskItem) {
        tasks = tasks.filter { $0.id != task.id }
        save()
    }

    func updateDirectory(_ directory: URL) {
        fileWatcher?.stop()
        let newURL = directory.appendingPathComponent("tasks.md")
        ensureDirectoryExists(directory)

        // Re-initialize with new path by reloading
        let content = MarkdownParser.readFile(at: newURL)
        tasks = MarkdownParser.parseTasks(from: content)
        startWatching()
    }

    private func save() {
        let content = MarkdownParser.serializeTasks(tasks)
        suppressNextReload = true
        do {
            try MarkdownParser.writeFile(content, to: fileURL)
        } catch {
            suppressNextReload = false
        }
    }

    private func startWatching() {
        // Ensure file exists before watching
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }

        fileWatcher = FileWatcher(url: fileURL) { [weak self] in
            guard let self else { return }
            if self.suppressNextReload {
                self.suppressNextReload = false
                return
            }
            self.load()
        }
    }

    private func ensureDirectoryExists(_ directory: URL) {
        try? FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }
}
