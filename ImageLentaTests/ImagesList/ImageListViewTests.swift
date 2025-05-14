//
//  ImageListViewTests.swift
//  ImageLenta
//
//  Created by Ди Di on 06/05/25.
//

import XCTest
@testable import ImageLenta


struct ImagesListScene {
    let service: MockImagesListService
    let view:   ImagesListViewSpy
    let presenter: ImagesListViewPresenter
    
    init(
        profile: ProfileService.Profile = .init(
            username: "test",
            name:     "Test",
            loginName:"@test",
            bio:      nil
        ),
        token: String = "test-token"
    ) {
        OAuth2TokenStorage.shared.token = token
        ProfileService.shared.profile = profile
        
        service   = MockImagesListService()
        view      = ImagesListViewSpy()
        presenter = ImagesListViewPresenter(imagesListService: service)
        presenter.view = view
    }
}

final class ImagesListTests: XCTestCase {
    func testFetchesPhotosAndUpdatesPhotos() {
        // given
        let scene = ImagesListScene()
        scene.service.photos = [scene.service.samplePhoto]
        
        // when
        scene.presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(scene.service.fetchCalled, "Presenter.viewDidLoad() вызвал fetchPhotosNextPage")
        XCTAssertTrue(scene.view.updateCalled, "После fetchPhotosNextPage() сработал view.updateTableViewAnimated()")
    }
    
    func testReturnsCorrectModelForPhoto() {
        // given
        let scene = ImagesListScene()
        scene.service.photos = [scene.service.samplePhoto]
        scene.presenter.viewDidLoad()
        
        // when
        let model = scene.presenter.photo(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertEqual(model.thumbImageURL, "https://example.com/thumb.jpg")
        XCTAssertFalse(model.isLiked)
    }
    
    func testDidTapLikeSuccess() {
        // given
        let scene = ImagesListScene()
        scene.service.photos = [scene.service.samplePhoto]
        scene.presenter.viewDidLoad()
        
        // when
        scene.presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertTrue(scene.service.likeCalled, "При тапе like вызовется changeLike()")
        XCTAssertTrue(scene.view.reloadCalled, "При успешном like презентер скажет view.reloadRow()")
    }
    
    func testDidTapLikeFailure() {
        // given
        let scene = ImagesListScene()
        scene.service.photos = [scene.service.samplePhoto]
        scene.service.shouldFailLike = true
        
        // when
        scene.presenter.viewDidLoad()
        let exp = expectation(description: "Photos loaded")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1)
        scene.presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertNotNil(scene.view.alertMessage)
    }
    
    func testPaginationTriggersFetch() {
        // given
        let scene = ImagesListScene()
        scene.service.photos = [scene.service.samplePhoto]
        scene.presenter.viewDidLoad()
        
        let exp = expectation(description: "Photos loaded")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1)
        
        scene.service.fetchCalled = false
        let lastIndex = scene.presenter.photosCount - 1
        
        // when
        scene.presenter.willDisplayCell(at: IndexPath(row: lastIndex, section: 0))
        
        // then
        XCTAssertTrue(scene.service.fetchCalled,
                      "При willDisplay последней ячейки (row=\(lastIndex)) презентер вызовет fetchPhotosNextPage()")
    }
}
