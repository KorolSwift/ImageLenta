//
//  Image_LentaTests.swift
//  Image LentaTests
//
//  Created by Ди Di on 19/04/25.
//

import XCTest
@testable import ImageLenta

final class ImagesListServiceTests: XCTestCase {
    func testExample() {
        let service = ImagesListService()
        let username = "test_user"
        let token = "Bearer _5HBmVYAl3fUXxezRU1-WZbUDOb2qxZsfV4kn26XPkI"
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        service.fetchPhotosNextPage(for: username, token: token) { result in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        XCTFail("Ошибка при загрузке фото: \(error)")
                    }
                }
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
        service.fetchPhotosNextPage(for: username, token: token) { result in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        XCTFail("Ошибка при загрузке фото: \(error)")
                    }
                }
        service.fetchPhotosNextPage(for: username, token: token) { result in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        XCTFail("Ошибка при загрузке фото: \(error)")
                    }
                }
        service.fetchPhotosNextPage(for: username, token: token) { result in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        XCTFail("Ошибка при загрузке фото: \(error)")
                    }
                }
    }
}
