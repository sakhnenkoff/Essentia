//
//  HomePresenterTests.swift
//  AppTemplateLiteUnitTests
//
//  Example tests demonstrating the Presenter testing pattern.
//  Use this as a template for testing other Presenters.
//

import Testing
import SwiftUI
@testable import AppTemplateLite

// MARK: - Mock Home Router

/// Screen-specific mock router extending the base MockGlobalRouter.
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

// MARK: - Mock Home Interactor

/// Screen-specific mock interactor extending the base MockGlobalInteractor.
@MainActor
class MockHomeInteractor: MockGlobalInteractor, HomeInteractor {
    // HomeInteractor has no additional requirements beyond GlobalInteractor
    // Add mock properties/methods here if the protocol is extended
}

// MARK: - Home Presenter Tests

@Suite("HomePresenter Tests")
struct HomePresenterTests {

    // MARK: - View Lifecycle Tests

    @MainActor
    @Test("onViewAppear tracks screen event")
    func onViewAppear_tracksScreenEvent() async throws {
        // Arrange
        let mockInteractor = MockHomeInteractor()
        let mockRouter = MockHomeRouter()
        let presenter = HomePresenter(interactor: mockInteractor, router: mockRouter)
        let delegate = HomeDelegate()

        // Act
        presenter.onViewAppear(delegate: delegate)

        // Assert
        #expect(mockInteractor.didTrackScreenEvent("HomeView_Appear"))
        #expect(mockInteractor.trackedScreenEvents.count == 1)
    }

    @MainActor
    @Test("onViewDisappear tracks event")
    func onViewDisappear_tracksEvent() async throws {
        // Arrange
        let mockInteractor = MockHomeInteractor()
        let mockRouter = MockHomeRouter()
        let presenter = HomePresenter(interactor: mockInteractor, router: mockRouter)
        let delegate = HomeDelegate()

        // Act
        presenter.onViewDisappear(delegate: delegate)

        // Assert
        #expect(mockInteractor.didTrackEvent("HomeView_Disappear"))
    }

    // MARK: - Navigation Tests

    #if MOCK || DEV
    @MainActor
    @Test("onDevSettingsPressed shows dev settings in debug builds")
    func onDevSettingsPressed_showsDevSettings_inDebugBuilds() async throws {
        // Arrange
        let mockInteractor = MockHomeInteractor()
        let mockRouter = MockHomeRouter()
        let presenter = HomePresenter(interactor: mockInteractor, router: mockRouter)

        // Act
        presenter.onDevSettingsPressed()

        // Assert
        #expect(mockRouter.showDevSettingsViewCalled)
        #expect(mockInteractor.didTrackEvent("HomeView_DevSettings"))
    }
    #endif

    // MARK: - Deep Link Tests

    @MainActor
    @Test("handleDeepLink with valid query items tracks success")
    func handleDeepLink_withValidQueryItems_tracksSuccess() async throws {
        // Arrange
        let mockInteractor = MockHomeInteractor()
        let mockRouter = MockHomeRouter()
        let presenter = HomePresenter(interactor: mockInteractor, router: mockRouter)
        let url = try #require(URL(string: "myapp://test?param=value"))

        // Act
        presenter.handleDeepLink(url: url)

        // Assert
        #expect(mockInteractor.didTrackEvent("HomeView_DeepLink_Start"))
        #expect(mockInteractor.didTrackEvent("HomeView_DeepLink_Success"))
        #expect(!mockInteractor.didTrackEvent("HomeView_DeepLink_NoItems"))
    }

    @MainActor
    @Test("handleDeepLink without query items tracks no items")
    func handleDeepLink_withoutQueryItems_tracksNoItems() async throws {
        // Arrange
        let mockInteractor = MockHomeInteractor()
        let mockRouter = MockHomeRouter()
        let presenter = HomePresenter(interactor: mockInteractor, router: mockRouter)
        let url = try #require(URL(string: "myapp://test"))

        // Act
        presenter.handleDeepLink(url: url)

        // Assert
        #expect(mockInteractor.didTrackEvent("HomeView_DeepLink_Start"))
        #expect(mockInteractor.didTrackEvent("HomeView_DeepLink_NoItems"))
        #expect(!mockInteractor.didTrackEvent("HomeView_DeepLink_Success"))
    }

    // MARK: - Push Notification Tests

    @MainActor
    @Test("handlePushNotification with userInfo tracks success")
    func handlePushNotification_withUserInfo_tracksSuccess() async throws {
        // Arrange
        let mockInteractor = MockHomeInteractor()
        let mockRouter = MockHomeRouter()
        let presenter = HomePresenter(interactor: mockInteractor, router: mockRouter)
        let notification = Notification(
            name: .fcmToken,
            object: nil,
            userInfo: ["key": "value"]
        )

        // Act
        presenter.handlePushNotificationRecieved(notification: notification)

        // Assert
        #expect(mockInteractor.didTrackEvent("HomeView_PushNotif_Start"))
        #expect(mockInteractor.didTrackEvent("HomeView_PushNotif_Success"))
    }

    @MainActor
    @Test("handlePushNotification without userInfo tracks no data")
    func handlePushNotification_withoutUserInfo_tracksNoData() async throws {
        // Arrange
        let mockInteractor = MockHomeInteractor()
        let mockRouter = MockHomeRouter()
        let presenter = HomePresenter(interactor: mockInteractor, router: mockRouter)
        let notification = Notification(name: .fcmToken)

        // Act
        presenter.handlePushNotificationRecieved(notification: notification)

        // Assert
        #expect(mockInteractor.didTrackEvent("HomeView_PushNotif_Start"))
        #expect(mockInteractor.didTrackEvent("HomeView_PushNotif_NoItems"))
    }
}

// MARK: - Testing Pattern Documentation
/*
 ## Presenter Testing Pattern

 1. **Create screen-specific mocks** by extending MockGlobalRouter and MockGlobalInteractor:
    - MockHomeRouter extends MockGlobalRouter, HomeRouter
    - MockHomeInteractor extends MockGlobalInteractor, HomeInteractor

 2. **Arrange** - Create mocks and presenter instance:
    ```swift
    let mockInteractor = MockHomeInteractor()
    let mockRouter = MockHomeRouter()
    let presenter = HomePresenter(interactor: mockInteractor, router: mockRouter)
    ```

 3. **Act** - Call the presenter method:
    ```swift
    presenter.onViewAppear(delegate: HomeDelegate())
    ```

 4. **Assert** - Check tracked events and mock state:
    ```swift
    #expect(mockInteractor.didTrackScreenEvent("HomeView_Appear"))
    #expect(mockRouter.showDevSettingsViewCalled)
    ```

 ## What to Test

 - **Event tracking**: Verify correct events are tracked with proper names
 - **Navigation**: Verify router methods are called
 - **State changes**: Verify presenter state is updated correctly
 - **Conditional logic**: Test different code paths (e.g., with/without data)
 - **Error handling**: Verify error events are tracked with .severe type

 ## Test Naming Convention

 Use descriptive names: `methodName_condition_expectedResult`
 - `onViewAppear_tracksScreenEvent`
 - `handleDeepLink_withValidQueryItems_tracksSuccess`
 - `handleDeepLink_withoutQueryItems_tracksNoItems`
 */
