import Foundation

enum MarkdownParser {

    // MARK: - Tasks

    static func parseTasks(from content: String) -> [TaskItem] {
        content
            .components(separatedBy: .newlines)
            .compactMap(parseTaskLine)
    }

    static func serializeTasks(_ tasks: [TaskItem]) -> String {
        let lines = tasks.map { task -> String in
            let checkbox = task.isCompleted ? "[x]" : "[ ]"
            let todaySuffix = task.isToday ? " #today" : ""
            return "- \(checkbox) \(task.text)\(todaySuffix)"
        }
        return lines.joined(separator: "\n") + (lines.isEmpty ? "" : "\n")
    }

    private static func parseTaskLine(_ line: String) -> TaskItem? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        let isCompleted: Bool
        let rawText: String

        if trimmed.hasPrefix("- [x] ") || trimmed.hasPrefix("- [X] ") {
            rawText = String(trimmed.dropFirst(6))
            isCompleted = true
        } else if trimmed.hasPrefix("- [ ] ") {
            rawText = String(trimmed.dropFirst(6))
            isCompleted = false
        } else {
            return nil
        }

        guard !rawText.isEmpty else { return nil }

        let isToday = rawText.hasSuffix(" #today")
        let text = isToday ? String(rawText.dropLast(7)) : rawText
        guard !text.isEmpty else { return nil }

        return TaskItem(text: text, isCompleted: isCompleted, isToday: isToday)
    }

    // MARK: - Notes

    static func parseNotes(from content: String) -> [NoteItem] {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

        let headerPrefix = "## "

        var notes: [NoteItem] = []
        var currentDate: Date?
        var currentLines: [String] = []

        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            if line.hasPrefix(headerPrefix),
               let date = parseNoteDate(String(line.dropFirst(headerPrefix.count))) {
                if let prevDate = currentDate {
                    let body = currentLines
                        .joined(separator: "\n")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !body.isEmpty {
                        notes.append(NoteItem(content: body, createdAt: prevDate))
                    }
                }
                currentDate = date
                currentLines = []
            } else {
                currentLines.append(line)
            }
        }

        if let date = currentDate {
            let body = currentLines
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !body.isEmpty {
                notes.append(NoteItem(content: body, createdAt: date))
            }
        }

        return notes
    }

    static func serializeNotes(_ notes: [NoteItem]) -> String {
        let blocks = notes.map { note -> String in
            let dateString = formatNoteDate(note.createdAt)
            return "## \(dateString)\n\n\(note.content)"
        }
        return blocks.joined(separator: "\n\n") + (blocks.isEmpty ? "" : "\n")
    }

    private static let noteDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static func parseNoteDate(_ string: String) -> Date? {
        noteDateFormatter.date(from: string)
    }

    private static func formatNoteDate(_ date: Date) -> String {
        noteDateFormatter.string(from: date)
    }

    // MARK: - File I/O

    static func readFile(at url: URL) -> String {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            return ""
        }
    }

    static func writeFile(_ content: String, to url: URL) throws {
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
}
