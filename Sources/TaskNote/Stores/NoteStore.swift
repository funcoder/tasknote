import Foundation
import Combine

final class NoteStore: ObservableObject {
    @Published private(set) var notes: [NoteItem] = []

    private let fileURL: URL
    private var fileWatcher: FileWatcher?
    private var suppressNextReload = false

    init(directory: URL) {
        self.fileURL = directory.appendingPathComponent("notes.md")
        ensureDirectoryExists(directory)
        load()
        startWatching()
    }

    func load() {
        let content = MarkdownParser.readFile(at: fileURL)
        notes = MarkdownParser.parseNotes(from: content)
    }

    func addNote(_ content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newNote = NoteItem(content: trimmed)
        notes = [newNote] + notes
        save()
    }

    func updateNote(_ note: NoteItem, content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        notes = notes.map { item in
            item.id == note.id ? item.withContent(trimmed) : item
        }
        save()
    }

    func deleteNote(_ note: NoteItem) {
        notes = notes.filter { $0.id != note.id }
        save()
    }

    func updateDirectory(_ directory: URL) {
        fileWatcher?.stop()
        let newURL = directory.appendingPathComponent("notes.md")
        ensureDirectoryExists(directory)

        let content = MarkdownParser.readFile(at: newURL)
        notes = MarkdownParser.parseNotes(from: content)
        startWatching()
    }

    private func save() {
        let content = MarkdownParser.serializeNotes(notes)
        suppressNextReload = true
        do {
            try MarkdownParser.writeFile(content, to: fileURL)
        } catch {
            suppressNextReload = false
        }
    }

    private func startWatching() {
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
