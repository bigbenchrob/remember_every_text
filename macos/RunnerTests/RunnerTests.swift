import Cocoa
import FlutterMacOS
import XCTest
@testable import MessageLens

class RunnerTests: XCTestCase {

  func testProcessLockAllowsOnlyOneOwner() throws {
    let lockURL = try temporaryLockURL()
    let first = MessageLensProcessLock()
    let second = MessageLensProcessLock()

    XCTAssertTrue(first.acquire(at: lockURL))
    XCTAssertFalse(second.acquire(at: lockURL))

    first.release()
    XCTAssertTrue(second.acquire(at: lockURL))
  }

  func testStaleLockFileCarriesNoAuthority() throws {
    let lockURL = try temporaryLockURL()
    try Data("stale".utf8).write(to: lockURL)

    let lock = MessageLensProcessLock()

    XCTAssertTrue(lock.acquire(at: lockURL))
  }

  func testContendedAuthorityClaimCannotBecomePrimary() throws {
    let lockURL = try temporaryLockURL()
    let first = MessageLensSingleInstanceAuthority(
      lockURL: lockURL,
      runningApplications: { [] }
    )
    let second = MessageLensSingleInstanceAuthority(
      lockURL: lockURL,
      runningApplications: { [] }
    )

    guard case .primary = first.claim() else {
      return XCTFail("The first authority should own the process lock.")
    }

    guard case .duplicate(let existingApplication) = second.claim() else {
      return XCTFail("A contended process lock must reject the second authority.")
    }
    XCTAssertNil(existingApplication)
  }

  private func temporaryLockURL() throws -> URL {
    let directoryURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(
      at: directoryURL,
      withIntermediateDirectories: true
    )
    addTeardownBlock {
      try? FileManager.default.removeItem(at: directoryURL)
    }
    return directoryURL.appendingPathComponent("MessageLens.instance.lock")
  }
}
