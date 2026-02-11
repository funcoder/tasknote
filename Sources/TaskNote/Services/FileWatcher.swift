import Foundation

final class FileWatcher {
    private var source: DispatchSourceFileSystemObject?
    private let fileDescriptor: Int32
    private let url: URL
    private let onChange: () -> Void

    init?(url: URL, onChange: @escaping () -> Void) {
        self.url = url
        self.onChange = onChange

        let path = url.path
        let fd = open(path, O_EVTONLY)
        guard fd >= 0 else { return nil }
        self.fileDescriptor = fd

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .rename, .delete],
            queue: .main
        )

        source.setEventHandler { [weak self] in
            self?.onChange()
        }

        source.setCancelHandler {
            close(fd)
        }

        self.source = source
        source.resume()
    }

    func restart() {
        stop()

        let fd = open(url.path, O_EVTONLY)
        guard fd >= 0 else { return }

        let newSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .rename, .delete],
            queue: .main
        )

        newSource.setEventHandler { [weak self] in
            self?.onChange()
        }

        newSource.setCancelHandler {
            close(fd)
        }

        self.source = newSource
        newSource.resume()
    }

    func stop() {
        source?.cancel()
        source = nil
    }

    deinit {
        stop()
    }
}
