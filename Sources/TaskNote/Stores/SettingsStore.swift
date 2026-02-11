import Foundation
import ServiceManagement

final class SettingsStore: ObservableObject {
    private static let storageDirectoryKey = "storageDirectory"
    private static let launchAtLoginKey = "launchAtLogin"

    private static let defaultDirectory: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TaskNote")
    }()

    @Published var storageDirectory: URL {
        didSet {
            UserDefaults.standard.set(
                storageDirectory.path,
                forKey: Self.storageDirectoryKey
            )
        }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Self.launchAtLoginKey)
            updateLoginItem()
        }
    }

    init() {
        if let savedPath = UserDefaults.standard.string(forKey: Self.storageDirectoryKey) {
            self.storageDirectory = URL(fileURLWithPath: savedPath)
        } else {
            self.storageDirectory = Self.defaultDirectory
        }

        self.launchAtLogin = UserDefaults.standard.bool(forKey: Self.launchAtLoginKey)
    }

    private func updateLoginItem() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Silently handle - login item registration can fail in dev builds
            }
        }
    }
}
