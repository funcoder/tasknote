import AppKit
import SwiftUI

enum CaptureMode {
    case task
    case note
}

final class PanelController {
    private var panel: QuickCapturePanel?
    private var onSubmit: ((String, CaptureMode) -> Void)?

    func configure(onSubmit: @escaping (String, CaptureMode) -> Void) {
        self.onSubmit = onSubmit
    }

    func showCapture(mode: CaptureMode) {
        let panel = getOrCreatePanel()
        let captureView = QuickCaptureView(
            mode: mode,
            onSubmit: { [weak self] text in
                self?.onSubmit?(text, mode)
                self?.dismiss()
            },
            onCancel: { [weak self] in
                self?.dismiss()
            }
        )

        panel.contentView = NSHostingView(rootView: captureView)
        panel.centerOnScreen()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func dismiss() {
        panel?.orderOut(nil)
    }

    private func getOrCreatePanel() -> QuickCapturePanel {
        if let existing = panel {
            return existing
        }
        let newPanel = QuickCapturePanel()
        panel = newPanel
        return newPanel
    }
}
