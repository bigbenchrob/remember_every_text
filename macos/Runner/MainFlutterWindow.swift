import Cocoa
import Darwin
import FlutterMacOS

final class MessageLensProcessLock {
  private var descriptor: Int32 = -1

  deinit {
    release()
  }

  func acquire(at lockURL: URL) -> Bool {
    if descriptor >= 0 {
      return true
    }

    do {
      try FileManager.default.createDirectory(
        at: lockURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
    } catch {
      NSLog("MessageLens could not create its instance-lock directory: \(error)")
      return false
    }

    let openedDescriptor = Darwin.open(
      lockURL.path,
      O_CREAT | O_RDWR,
      S_IRUSR | S_IWUSR
    )
    guard openedDescriptor >= 0 else {
      NSLog("MessageLens could not open its instance lock at \(lockURL.path)")
      return false
    }

    guard flock(openedDescriptor, LOCK_EX | LOCK_NB) == 0 else {
      Darwin.close(openedDescriptor)
      return false
    }

    descriptor = openedDescriptor
    return true
  }

  func release() {
    guard descriptor >= 0 else {
      return
    }

    flock(descriptor, LOCK_UN)
    Darwin.close(descriptor)
    descriptor = -1
  }
}

enum MessageLensInstanceClaim {
  case primary
  case duplicate(existingApplication: NSRunningApplication?)
}

final class MessageLensSingleInstanceAuthority {
  private let processLock: MessageLensProcessLock
  private let lockURL: URL
  private let runningApplications: () -> [NSRunningApplication]

  init(
    processLock: MessageLensProcessLock = MessageLensProcessLock(),
    lockURL: URL? = nil,
    runningApplications: (() -> [NSRunningApplication])? = nil
  ) {
    self.processLock = processLock
    self.lockURL = lockURL ?? Self.defaultLockURL
    self.runningApplications = runningApplications ?? {
      guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
        return []
      }

      return NSRunningApplication.runningApplications(
        withBundleIdentifier: bundleIdentifier
      )
    }
  }

  func claim() -> MessageLensInstanceClaim {
    if let earlierApplication = earlierRunningApplication() {
      return .duplicate(existingApplication: earlierApplication)
    }

    guard processLock.acquire(at: lockURL) else {
      return .duplicate(existingApplication: otherRunningApplication())
    }

    return .primary
  }

  private func earlierRunningApplication() -> NSRunningApplication? {
    let current = NSRunningApplication.current
    return matchingRunningApplications()
      .filter { application in
        guard application.processIdentifier != current.processIdentifier else {
          return false
        }

        let applicationLaunchDate = application.launchDate ?? .distantPast
        let currentLaunchDate = current.launchDate ?? .distantFuture
        if applicationLaunchDate != currentLaunchDate {
          return applicationLaunchDate < currentLaunchDate
        }

        return application.processIdentifier < current.processIdentifier
      }
      .min { lhs, rhs in
        let lhsLaunchDate = lhs.launchDate ?? .distantPast
        let rhsLaunchDate = rhs.launchDate ?? .distantPast
        if lhsLaunchDate != rhsLaunchDate {
          return lhsLaunchDate < rhsLaunchDate
        }
        return lhs.processIdentifier < rhs.processIdentifier
      }
  }

  private func otherRunningApplication() -> NSRunningApplication? {
    let currentProcessIdentifier = NSRunningApplication.current.processIdentifier
    return matchingRunningApplications().first { application in
      application.processIdentifier != currentProcessIdentifier
    }
  }

  private func matchingRunningApplications() -> [NSRunningApplication] {
    runningApplications()
  }

  private static let defaultLockURL: URL = {
    let applicationSupportURL = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    ).first!
    return applicationSupportURL
      .appendingPathComponent(
        "com.bigbenchsoftware.MessageLens",
        isDirectory: true
      )
      .appendingPathComponent("MessageLens.instance.lock")
  }()
}

class MainFlutterWindow: NSWindow {
  private static var instanceAuthority: MessageLensSingleInstanceAuthority?

  override func awakeFromNib() {
    let instanceAuthority = MessageLensSingleInstanceAuthority()
    switch instanceAuthority.claim() {
    case .duplicate(let existingApplication):
      super.awakeFromNib()
      orderOut(nil)
      existingApplication?.activate(options: [.activateAllWindows])
      DispatchQueue.main.async {
        NSApplication.shared.terminate(nil)
      }
      return
    case .primary:
      Self.instanceAuthority = instanceAuthority
    }

    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
