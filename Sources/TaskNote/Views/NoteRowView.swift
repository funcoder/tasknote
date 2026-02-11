import SwiftUI

struct NoteRowView: View {
    let note: NoteItem
    let onUpdate: (String) -> Void
    let onDelete: () -> Void

    @State private var isEditing = false
    @State private var editContent = ""
    @FocusState private var isEditFocused: Bool

    var body: some View {
        if isEditing {
            editView
        } else {
            displayView
        }
    }

    private var displayView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.content)
                .lineLimit(3)
                .font(.system(size: 13))

            Text(note.relativeTimestamp)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { startEditing() }
        .contextMenu {
            Button("Edit") { startEditing() }
            Divider()
            Button("Delete", role: .destructive, action: onDelete)
        }
    }

    private var editView: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextEditor(text: $editContent)
                .font(.system(size: 13))
                .focused($isEditFocused)
                .frame(minHeight: 60, maxHeight: 120)
                .scrollContentBackground(.hidden)
                .padding(4)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(4)

            HStack(spacing: 8) {
                Spacer()
                Button("Cancel") { cancelEdit() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))
                    .keyboardShortcut(.escape, modifiers: [])

                Button("Save") { commitEdit() }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    .font(.system(size: 12, weight: .medium))
                    .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }

    private func startEditing() {
        editContent = note.content
        isEditing = true
        isEditFocused = true
    }

    private func commitEdit() {
        let trimmed = editContent.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed != note.content {
            onUpdate(trimmed)
        }
        isEditing = false
    }

    private func cancelEdit() {
        isEditing = false
    }
}
