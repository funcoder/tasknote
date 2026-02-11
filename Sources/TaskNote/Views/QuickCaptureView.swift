import SwiftUI

struct QuickCaptureView: View {
    let mode: CaptureMode
    let onSubmit: (String) -> Void
    let onCancel: () -> Void

    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: mode == .task ? "checkmark.circle" : "note.text")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 18))
                .focused($isFocused)
                .onSubmit {
                    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    onSubmit(trimmed)
                }

            Text("esc")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .onAppear {
            isFocused = true
        }
        .onExitCommand {
            onCancel()
        }
    }

    private var placeholder: String {
        mode == .task ? "Add a task..." : "Add a note..."
    }
}
