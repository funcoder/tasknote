import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsStore: SettingsStore
    let onDirectoryChanged: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)

            // Storage directory
            VStack(alignment: .leading, spacing: 6) {
                Text("Storage Directory")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    Text(settingsStore.storageDirectory.path)
                        .font(.system(size: 12, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button("Change...") {
                        pickDirectory()
                    }
                    .controlSize(.small)
                }
            }

            Divider()

            // Launch at login
            Toggle("Launch at Login", isOn: $settingsStore.launchAtLogin)

            Divider()

            // Shortcuts
            VStack(alignment: .leading, spacing: 6) {
                Text("Keyboard Shortcuts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ShortcutRow(label: "Quick Task", shortcut: "Cmd + Enter")
                ShortcutRow(label: "Quick Note", shortcut: "Cmd + Shift + Enter")
            }

            Divider()

            // Quit
            Button("Quit TaskNote") {
                NSApplication.shared.terminate(nil)
            }
            .controlSize(.small)

            Spacer()
        }
        .padding(16)
    }

    private func pickDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"
        panel.message = "Select a directory for TaskNote data"

        if panel.runModal() == .OK, let url = panel.url {
            settingsStore.storageDirectory = url
            onDirectoryChanged(url)
        }
    }
}

private struct ShortcutRow: View {
    let label: String
    let shortcut: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
            Spacer()
            Text(shortcut)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
        }
    }
}
