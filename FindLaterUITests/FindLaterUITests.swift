import XCTest

final class FindLaterUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCreateMemoThenFindBySearchAndBrowse() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-store"]
        app.launch()

        app.buttons["composeButton"].tap()

        let body = app.textViews["memoBodyEditor"]
        XCTAssertTrue(body.waitForExistence(timeout: 5))
        body.tap()
        body.typeText("회의 끝나고 민지한테 데모 링크 보내기")

        let tagInput = app.textFields["tagInput"]
        tagInput.tap()
        tagInput.typeText("데모")
        app.keyboards.buttons["return"].tap()

        app.buttons["저장"].tap()

        XCTAssertTrue(app.staticTexts["회의 끝나고 민지한테 데모 링크 보내기"].waitForExistence(timeout: 5))

        app.tabBars.buttons["검색"].tap()
        let searchField = app.textFields["searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("민지")
        XCTAssertTrue(app.staticTexts["회의 끝나고 민지한테 데모 링크 보내기"].waitForExistence(timeout: 5))

        app.tabBars.buttons["탐색"].tap()
        XCTAssertTrue(app.buttons["category-업무"].waitForExistence(timeout: 5))
        app.buttons["category-업무"].tap()
        XCTAssertTrue(app.staticTexts["회의 끝나고 민지한테 데모 링크 보내기"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["AI 자동 분류 예정"].exists)
    }
}
