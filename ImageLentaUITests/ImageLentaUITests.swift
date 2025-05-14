//
//  ImageLentaUITests.swift
//  ImageLentaUITests
//
//  Created by Ди Di on 20/02/25.
//

import XCTest


class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("email\t")
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        
        let letterKey = app.keyboards.buttons["ABC"]
        if letterKey.waitForExistence(timeout: 1) {
            letterKey.tap()
        }
        
        passwordTextField.typeText("password\n")
        
        let feedTable = app.tables["ImagesListTable"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10), "Таблица ленты не появилась")
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        let app = XCUIApplication()
        let feedTable = app.tables["ImagesListTable"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10), "Лента не загрузилась")

        let сell = feedTable.cells.element(boundBy: 1)
        var attempts = 0
        while !сell.exists || !сell.isHittable {
            feedTable.swipeUp()
            sleep(1)
            attempts += 1
            if attempts > 8 {
                XCTFail("Не удалось доскроллить до ячейки")
                return
            }
        }

        let likeButton = сell.buttons["likeButton"]
        XCTAssertTrue(likeButton.exists, "Кнопка лайка не найдена")
        likeButton.tap()
        sleep(1)
        likeButton.tap()
        sleep(1)

        сell.tap()
        sleep(2)

        let image = app.images["FullSizeImage"]
        XCTAssertTrue(image.waitForExistence(timeout: 10), "Полноэкранное изображение не появилось")

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let backButton = app.buttons["nav back button white"]
        XCTAssertTrue(backButton.exists, "Кнопка назад не найдена")
        backButton.tap()
    }
    
    func testProfileLogout() throws {
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5), "Кнопка профиля не найдена")
        profileTab.tap()
        
        let nameLabel = app.staticTexts.element(boundBy: 0)
        XCTAssertTrue(nameLabel.exists)
        XCTAssertEqual(nameLabel.label, "Diana ")
        
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 3), "Кнопка выхода не найдена")
        logoutButton.tap()
        
        let logoutAlert = app.alerts["Пока, пока!"]
        XCTAssertTrue(logoutAlert.waitForExistence(timeout: 5), "Алерт подтверждения выхода не появился")
        
        let yesButton = logoutAlert.buttons["Да"]
        XCTAssertTrue(yesButton.exists, "Кнопка 'Да'не найдена")
        yesButton.tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Экран авторизации не появился")
    }
}
