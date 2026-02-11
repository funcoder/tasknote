import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    private let settingsStore = SettingsStore()
    private var taskStore: TaskStore!
    private var noteStore: NoteStore!
    private let panelController = PanelController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        taskStore = TaskStore(directory: settingsStore.storageDirectory)
        noteStore = NoteStore(directory: settingsStore.storageDirectory)

        setupStatusItem()
        setupPopover()
        setupHotkeys()
        setupPanelController()
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "checklist",
                accessibilityDescription: "TaskNote"
            )
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    // MARK: - Popover

    private func setupPopover() {
        let contentView = MenuPopoverView(
            taskStore: taskStore,
            noteStore: noteStore,
            settingsStore: settingsStore,
            onDirectoryChanged: { [weak self] newDir in
                self?.taskStore.updateDirectory(newDir)
                self?.noteStore.updateDirectory(newDir)
            }
        )

        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - Hotkeys

    private func setupHotkeys() {
        HotkeyService.shared.register { [weak self] action in
            guard let self else { return }
            switch action {
            case .newTask:
                self.panelController.showCapture(mode: .task)
            case .newNote:
                self.panelController.showCapture(mode: .note)
            }
        }
    }

    // MARK: - Panel Controller

    private func setupPanelController() {
        panelController.configure { [weak self] text, mode in
            guard let self else { return }
            switch mode {
            case .task:
                self.taskStore.addTask(text)
            case .note:
                self.noteStore.addNote(text)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotkeyService.shared.unregister()
    }
}
