import Cocoa
import FlutterMacOS
import XCTest
@testable import MessageLens

class RunnerTests: XCTestCase {

  func testDevelopmentClaimResolvesDevelopmentRoot() throws {
    let applicationSupportURL = URL(fileURLWithPath: "/tmp/ApplicationSupport")
    let resolver = MessageLensNativeArchiveClaimResolver(
      bundleInfo: developmentBundleInfo(),
      bundleIdentifier: "com.bigbenchsoftware.MessageLens.development",
      applicationSupportURL: applicationSupportURL,
      processEnvironment: [:],
      signatureValidator: { _ in false }
    )

    let claim = try resolver.resolve()

    XCTAssertEqual(claim.environment, .development)
    XCTAssertEqual(claim.buildIdentity, .developmentDebug)
    XCTAssertEqual(
      claim.canonicalRootURL.path,
      "/tmp/ApplicationSupport/com.bigbenchsoftware.MessageLens.development"
    )
    XCTAssertTrue(claim.productionSignatureIsValid)
  }

  func testBuildEnvironmentMismatchIsRejected() {
    var bundleInfo = developmentBundleInfo()
    bundleInfo["MessageLensArchiveBuildIdentity"] = "productionRelease"
    let resolver = MessageLensNativeArchiveClaimResolver(
      bundleInfo: bundleInfo,
      bundleIdentifier: "com.bigbenchsoftware.MessageLens.development",
      applicationSupportURL: URL(fileURLWithPath: "/tmp/ApplicationSupport"),
      processEnvironment: [:],
      signatureValidator: { _ in true }
    )

    XCTAssertThrowsError(try resolver.resolve()) { error in
      XCTAssertEqual(
        error as? MessageLensNativeArchiveClaimError,
        .buildEnvironmentMismatch
      )
    }
  }

  func testProductionClaimRejectsUnexpectedSignature() {
    let resolver = MessageLensNativeArchiveClaimResolver(
      bundleInfo: [
        "MessageLensArchiveEnvironment": "production",
        "MessageLensArchiveBuildIdentity": "productionRelease",
        "MessageLensExpectedSigningIdentity":
          "Developer ID Application: Robert Campbell (FQHT2QP3NE)",
        "CFBundleDisplayName": "MessageLens",
      ],
      bundleIdentifier: "com.bigbenchsoftware.MessageLens",
      applicationSupportURL: URL(fileURLWithPath: "/tmp/ApplicationSupport"),
      processEnvironment: [:],
      signatureValidator: { _ in false }
    )

    XCTAssertThrowsError(try resolver.resolve()) { error in
      XCTAssertEqual(
        error as? MessageLensNativeArchiveClaimError,
        .invalidProductionSignature
      )
    }
  }

  func testDevelopmentAndProductionClaimsUseDifferentLocks() throws {
    let applicationSupportURL = URL(fileURLWithPath: "/tmp/ApplicationSupport")
    let developmentClaim = try MessageLensNativeArchiveClaimResolver(
      bundleInfo: developmentBundleInfo(),
      bundleIdentifier: "com.bigbenchsoftware.MessageLens.development",
      applicationSupportURL: applicationSupportURL,
      processEnvironment: [:],
      signatureValidator: { _ in false }
    ).resolve()
    let productionClaim = try MessageLensNativeArchiveClaimResolver(
      bundleInfo: [
        "MessageLensArchiveEnvironment": "production",
        "MessageLensArchiveBuildIdentity": "productionRelease",
        "MessageLensExpectedSigningIdentity": "expected",
        "CFBundleDisplayName": "MessageLens",
      ],
      bundleIdentifier: "com.bigbenchsoftware.MessageLens",
      applicationSupportURL: applicationSupportURL,
      processEnvironment: [:],
      signatureValidator: { _ in true }
    ).resolve()

    XCTAssertNotEqual(
      developmentClaim.canonicalRootURL
        .appendingPathComponent("MessageLens.instance.lock"),
      productionClaim.canonicalRootURL
        .appendingPathComponent("MessageLens.instance.lock")
    )
  }

  func testDevelopmentClaimUsesAvailableConfiguredRoot() throws {
    let configuredRootURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(
      at: configuredRootURL,
      withIntermediateDirectories: true
    )
    addTeardownBlock {
      try? FileManager.default.removeItem(at: configuredRootURL)
    }

    let claim = try MessageLensNativeArchiveClaimResolver(
      bundleInfo: developmentBundleInfo(),
      bundleIdentifier: "com.bigbenchsoftware.MessageLens.development",
      applicationSupportURL: URL(fileURLWithPath: "/tmp/ApplicationSupport"),
      processEnvironment: [
        "MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT": configuredRootURL.path
      ],
      signatureValidator: { _ in false }
    ).resolve()

    XCTAssertEqual(
      claim.canonicalRootURL,
      configuredRootURL.resolvingSymlinksInPath().standardizedFileURL
    )
  }

  func testDevelopmentClaimRejectsUnavailableConfiguredRoot() {
    let missingRootURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let resolver = MessageLensNativeArchiveClaimResolver(
      bundleInfo: developmentBundleInfo(),
      bundleIdentifier: "com.bigbenchsoftware.MessageLens.development",
      applicationSupportURL: URL(fileURLWithPath: "/tmp/ApplicationSupport"),
      processEnvironment: [
        "MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT": missingRootURL.path
      ],
      signatureValidator: { _ in false }
    )

    XCTAssertThrowsError(try resolver.resolve()) { error in
      XCTAssertEqual(
        error as? MessageLensNativeArchiveClaimError,
        .unavailableDevelopmentRootOverride(missingRootURL.path)
      )
    }
  }

  func testProductionClaimRejectsDevelopmentRootOverride() {
    let resolver = MessageLensNativeArchiveClaimResolver(
      bundleInfo: [
        "MessageLensArchiveEnvironment": "production",
        "MessageLensArchiveBuildIdentity": "productionRelease",
        "MessageLensExpectedSigningIdentity": "expected",
        "CFBundleDisplayName": "MessageLens",
      ],
      bundleIdentifier: "com.bigbenchsoftware.MessageLens",
      applicationSupportURL: URL(fileURLWithPath: "/tmp/ApplicationSupport"),
      processEnvironment: [
        "MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT": "/tmp/development"
      ],
      signatureValidator: { _ in true }
    )

    XCTAssertThrowsError(try resolver.resolve()) { error in
      XCTAssertEqual(
        error as? MessageLensNativeArchiveClaimError,
        .developmentRootOverrideNotPermitted
      )
    }
  }

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

  private func developmentBundleInfo() -> [String: Any] {
    return [
      "MessageLensArchiveEnvironment": "development",
      "MessageLensArchiveBuildIdentity": "developmentDebug",
      "MessageLensExpectedSigningIdentity": "",
      "CFBundleDisplayName": "MessageLens Development",
    ]
  }
}
