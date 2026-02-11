import Carbon
import AppKit

enum HotkeyAction {
    case newTask
    case newNote
}

final class HotkeyService {
    private var taskHotkeyRef: EventHotKeyRef?
    private var noteHotkeyRef: EventHotKeyRef?
    private var onHotkey: ((HotkeyAction) -> Void)?

    private static let taskHotkeyID = UInt32(1)
    private static let noteHotkeyID = UInt32(2)

    static let shared = HotkeyService()

    private init() {}

    func register(onHotkey: @escaping (HotkeyAction) -> Void) {
        self.onHotkey = onHotkey
        installHandler()
        registerHotkeys()
    }

    func unregister() {
        if let ref = taskHotkeyRef {
            UnregisterEventHotKey(ref)
            taskHotkeyRef = nil
        }
        if let ref = noteHotkeyRef {
            UnregisterEventHotKey(ref)
            noteHotkeyRef = nil
        }
    }

    private func installHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData -> OSStatus in
                guard let userData else { return OSStatus(eventNotHandledErr) }
                let service = Unmanaged<HotkeyService>.fromOpaque(userData)
                    .takeUnretainedValue()

                var hotkeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotkeyID
                )

                switch hotkeyID.id {
                case HotkeyService.taskHotkeyID:
                    DispatchQueue.main.async {
                        service.onHotkey?(.newTask)
                    }
                case HotkeyService.noteHotkeyID:
                    DispatchQueue.main.async {
                        service.onHotkey?(.newNote)
                    }
                default:
                    return OSStatus(eventNotHandledErr)
                }

                return noErr
            },
            1,
            &eventType,
            selfPtr,
            nil
        )
    }

    private func registerHotkeys() {
        // Cmd+Enter = new task
        let taskID = EventHotKeyID(
            signature: OSType(0x544E_5431), // "TNT1"
            id: Self.taskHotkeyID
        )
        RegisterEventHotKey(
            UInt32(kVK_Return),
            UInt32(cmdKey),
            taskID,
            GetApplicationEventTarget(),
            0,
            &taskHotkeyRef
        )

        // Cmd+Shift+Enter = new note
        let noteID = EventHotKeyID(
            signature: OSType(0x544E_5432), // "TNT2"
            id: Self.noteHotkeyID
        )
        RegisterEventHotKey(
            UInt32(kVK_Return),
            UInt32(cmdKey | shiftKey),
            noteID,
            GetApplicationEventTarget(),
            0,
            &noteHotkeyRef
        )
    }
}
