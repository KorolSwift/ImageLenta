//
//  ProfileViewTests.swift
//  ImageLenta
//
//  Created by Ди Di on 06/05/25.
//

import XCTest
@testable import ImageLenta


final class ProfileViewTests: XCTestCase {
    func testSetsProfileInfoViewDidLoad() {
        // given
        let spyView = ProfileViewControllerSpy()
        let mockService = MockProfileService()
        let presenter = ProfileViewPresenter(profileService: mockService)
        presenter.view = spyView
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(spyView.setProfileInfoCalled)
        XCTAssertEqual(spyView.receivedName, "Mock User")
        XCTAssertEqual(spyView.receivedUsername, "@mock_user")
        XCTAssertEqual(spyView.receivedDescription, "Test profile")
    }
    
    func testShowsAlertDidTapLogout() {
        // given
        let spyView = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(profileService: MockProfileService())
        presenter.view = spyView
        
        // when
        presenter.didTapLogout()
        
        // then
        XCTAssertTrue(spyView.showLogoutAlertCalled)
    }
    
    func testSetsAvatarViewDidLoad() {
        // given
        let spyView = ProfileViewControllerSpy()
        let mockProfileService = MockProfileService()
        let mockImageService = MockProfileImageService()
        let presenter = ProfileViewPresenter(
            profileService: mockProfileService,
            profileImageService: mockImageService
        )
        presenter.view = spyView
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(spyView.setAvatarCalled)
        XCTAssertEqual(spyView.receivedAvatarURL?.absoluteString, "https://example.com/avatar.png")
    }
}
