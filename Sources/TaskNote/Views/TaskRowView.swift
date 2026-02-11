import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onUpdate: (String) -> Void
    let onTodayToggle: () -> Void
    let onDelete: () -> Void

    @State private var isEditing = false
    @State private var editText = ""
    @FocusState private var isEditFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            if isEditing {
                TextField("Task", text: $editText)
                    .textFieldStyle(.plain)
                    .focused($isEditFocused)
                    .onSubmit(commitEdit)
                    .onExitCommand(perform: cancelEdit)
            } else {
                HStack(spacing: 4) {
                    Text(task.text)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                        .lineLimit(2)

                    if task.isToday {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                    }
                }
                .onTapGesture(count: 2) { startEditing() }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
        .contextMenu {
            Button("Edit") { startEditing() }

            if task.isToday {
                Button("Remove from Today", action: onTodayToggle)
            } else {
                Button("Add to Today", action: onTodayToggle)
            }

            Divider()
            Button("Delete", role: .destructive, action: onDelete)
        }
    }

    private func startEditing() {
        editText = task.text
        isEditing = true
        isEditFocused = true
    }

    private func commitEdit() {
        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed != task.text {
            onUpdate(trimmed)
        }
        isEditing = false
    }

    private func cancelEdit() {
        isEditing = false
    }
}
