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
        let createdCard = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "회의 끝나고 민지한테 데모 링크 보내기")).firstMatch
        XCTAssertTrue(createdCard.waitForExistence(timeout: 5))
        createdCard.tap()
        XCTAssertTrue(app.otherElements["memoDetail"].waitForExistence(timeout: 5))
        app.buttons["닫기"].tap()

        app.tabBars.buttons["검색"].tap()
        let searchField = app.textFields["searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("민지")
        XCTAssertTrue(app.staticTexts["회의 끝나고 민지한테 데모 링크 보내기"].waitForExistence(timeout: 5))
        app.keyboards.buttons["return"].tap()

        app.tabBars.buttons["탐색"].tap()
        XCTAssertTrue(app.buttons["category-업무"].waitForExistence(timeout: 5))
        app.buttons["category-업무"].tap()
        XCTAssertTrue(app.staticTexts["회의 끝나고 민지한테 데모 링크 보내기"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["AI 자동 분류 예정"].exists)
    }

    func testManualAISuggestionsRequireApply() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-store"]
        app.launch()

        let card = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "노트북 블루스크린")).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        card.tap()

        XCTAssertTrue(app.otherElements["memoDetail"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["requestAIButton"].waitForExistence(timeout: 5))
        app.buttons["requestAIButton"].tap()

        XCTAssertTrue(app.buttons["applyAISuggestionsButton"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["추천 완료"].exists)
        app.buttons["applyAISuggestionsButton"].tap()

        XCTAssertTrue(app.staticTexts["문제해결"].exists)
        XCTAssertTrue(app.buttons["tag-블루스크린"].exists)
    }

    func testNaturalLanguageSearchFindsRelatedMemo() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-store", "--search", "지난번 노트북 고장 관련해서 적어둔 거"]
        app.launch()

        XCTAssertTrue(app.staticTexts["AI 검색 보조"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["노트북 블루스크린"].waitForExistence(timeout: 5))
    }
}
