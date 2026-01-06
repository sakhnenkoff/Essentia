//
//  PresenterTestHelpers.swift
//  AppTemplateLiteUnitTests
//
//  Base mock classes for testing Presenters in isolation.
//  Extend these for screen-specific mocks.
//

import Foundation
import SwiftUI
import SwiftfulRouting
@testable import AppTemplateLite

// MARK: - Mock Global Router

/// Base mock router for testing navigation behavior.
/// Tracks method calls for assertions.
@MainActor
class MockGlobalRouter: GlobalRouter {

    // MARK: - Protocol Requirement

    /// Mock router that tracks calls but doesn't perform actual navigation
    var router: AnyRouter {
        fatalError("MockGlobalRouter.router should not be accessed in unit tests. Use the tracking properties instead.")
    }

    // MARK: - Call Tracking

    var dismissScreenCalled = false
    var dismissEnvironmentCalled = false
    var dismissPushStackCalled = false
    var dismissModalCalled = false
    var dismissAlertCalled = false

    var showAlertCalled = false
    var lastAlertTitle: String?
    var lastAlertSubtitle: String?
    var lastAlertStyle: AlertStyle?

    var showSimpleAlertCalled = false
    var showErrorAlertCalled = false
    var lastError: Error?

    // MARK: - Mock Implementations

    func dismissScreen() {
        dismissScreenCalled = true
    }

    func dismissEnvironment() {
        dismissEnvironmentCalled = true
    }

    func dismissPushStack() {
        dismissPushStackCalled = true
    }

    func dismissModal() {
        dismissModalCalled = true
    }

    func dismissAlert() {
        dismissAlertCalled = true
    }

    func showAlert(_ option: AlertStyle, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        showAlertCalled = true
        lastAlertStyle = option
        lastAlertTitle = title
        lastAlertSubtitle = subtitle
    }

    func showSimpleAlert(title: String, subtitle: String?) {
        showSimpleAlertCalled = true
        lastAlertTitle = title
        lastAlertSubtitle = subtitle
    }

    func showAlert(error: Error) {
        showErrorAlertCalled = true
        lastError = error
        lastAlertTitle = "Error"
        lastAlertSubtitle = error.localizedDescription
    }

    // MARK: - Reset

    func reset() {
        dismissScreenCalled = false
        dismissEnvironmentCalled = false
        dismissPushStackCalled = false
        dismissModalCalled = false
        dismissAlertCalled = false
        showAlertCalled = false
        showSimpleAlertCalled = false
        showErrorAlertCalled = false
        lastAlertTitle = nil
        lastAlertSubtitle = nil
        lastAlertStyle = nil
        lastError = nil
    }
}

// MARK: - Mock Global Interactor

/// Base mock interactor for testing data access and event tracking.
/// Tracks method calls for assertions.
@MainActor
class MockGlobalInteractor: GlobalInteractor {

    // MARK: - Event Tracking

    var trackedEvents: [String] = []
    var trackedScreenEvents: [String] = []
    var allTrackedParameters: [[String: Any]?] = []
    var allTrackedTypes: [LogType] = []

    // MARK: - Haptic Tracking

    var hapticPlayed: HapticOption?
    var hapticPlayedCount: Int = 0

    // MARK: - Protocol Implementations

    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType) {
        trackedEvents.append(eventName)
        allTrackedParameters.append(parameters)
        allTrackedTypes.append(type)
    }

    func trackEvent(event: AnyLoggableEvent) {
        trackedEvents.append(event.eventName)
        allTrackedParameters.append(event.parameters)
        allTrackedTypes.append(event.type)
    }

    func trackEvent(event: LoggableEvent) {
        trackedEvents.append(event.eventName)
        allTrackedParameters.append(event.parameters)
        allTrackedTypes.append(event.type)
    }

    func trackScreenEvent(event: LoggableEvent) {
        trackedScreenEvents.append(event.eventName)
        allTrackedParameters.append(event.parameters)
        allTrackedTypes.append(event.type)
    }

    func playHaptic(option: HapticOption) {
        hapticPlayed = option
        hapticPlayedCount += 1
    }

    // MARK: - Assertion Helpers

    /// Check if a specific event was tracked
    func didTrackEvent(_ eventName: String) -> Bool {
        trackedEvents.contains(eventName) || trackedScreenEvents.contains(eventName)
    }

    /// Check if a specific screen event was tracked
    func didTrackScreenEvent(_ eventName: String) -> Bool {
        trackedScreenEvents.contains(eventName)
    }

    /// Get the index of a tracked event (for checking parameters)
    func indexOfEvent(_ eventName: String) -> Int? {
        if let index = trackedEvents.firstIndex(of: eventName) {
            return index
        }
        if let index = trackedScreenEvents.firstIndex(of: eventName) {
            return trackedEvents.count + index
        }
        return nil
    }

    // MARK: - Reset

    func reset() {
        trackedEvents.removeAll()
        trackedScreenEvents.removeAll()
        allTrackedParameters.removeAll()
        allTrackedTypes.removeAll()
        hapticPlayed = nil
        hapticPlayedCount = 0
    }
}

// MARK: - Test Error

/// A simple error for use in tests
struct TestError: Error, LocalizedError {
    let message: String

    init(_ message: String = "Test error") {
        self.message = message
    }

    var errorDescription: String? { message }
}

// MARK: - Usage Example
/*
 // Create a screen-specific mock router:

 @MainActor
 class MockHomeRouter: MockGlobalRouter, HomeRouter {
     var showDevSettingsViewCalled = false

     func showDevSettingsView() {
         showDevSettingsViewCalled = true
     }

     override func reset() {
         super.reset()
         showDevSettingsViewCalled = false
     }
 }

 // Create a screen-specific mock interactor:

 @MainActor
 class MockHomeInteractor: MockGlobalInteractor, HomeInteractor {
     // Add any screen-specific properties/methods
 }

 // Use in tests:

 @Suite("HomePresenter Tests")
 struct HomePresenterTests {

     @MainActor
     @Test func onViewAppear_tracksScreenEvent() async throws {
         // Arrange
         let mockInteractor = MockHomeInteractor()
         let mockRouter = MockHomeRouter()
         let presenter = HomePresenter(interactor: mockInteractor, router: mockRouter)

         // Act
         presenter.onViewAppear(delegate: HomeDelegate())

         // Assert
         #expect(mockInteractor.didTrackScreenEvent("HomeView_Appear"))
     }

     @MainActor
     @Test func onDevSettingsPressed_showsDevSettings() async throws {
         // Arrange
         let mockInteractor = MockHomeInteractor()
         let mockRouter = MockHomeRouter()
         let presenter = HomePresenter(interactor: mockInteractor, router: mockRouter)

         // Act
         presenter.onDevSettingsPressed()

         // Assert
         #expect(mockRouter.showDevSettingsViewCalled)
     }
 }
 */
