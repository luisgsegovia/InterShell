//
//  InterShellUITests.swift
//  InterShellUITests
//
//  Created by Luis Segovia on 09/03/23.
//

import XCTest

final class InterShellUITests: XCTestCase {
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testButtonsAreDetected() {
        let app = XCUIApplication()
        app.launchArguments = ["isRunningUITests"]
        app.launch()

        let timeout = 2.0
        let setButton = app.buttons["SET"]
        XCTAssertTrue(setButton.waitForExistence(timeout: timeout))
    }

    func test_tappingBeginTransactionButtonActivatesCommitAndRollbackButtons() {
        let app = XCUIApplication()
        app.launchArguments = ["isRunningUITests"]
        app.launch()

        let timeout = 2.0
        let beginButton = app.buttons["SET"]
        let commitButton = app.buttons["COMMIT"]
        let rollbackButton = app.buttons["ROLLBACK"]


        XCTAssertTrue(beginButton.waitForExistence(timeout: timeout))
        XCTAssertTrue(commitButton.waitForExistence(timeout: timeout))
        XCTAssertTrue(rollbackButton.waitForExistence(timeout: timeout))

        XCTAssertFalse(commitButton.isEnabled)
        XCTAssertFalse(rollbackButton.isEnabled)
    }

    func test_insertingTextInTextFieldsUpdatesViewModelValues() {
        let app = XCUIApplication()
        app.launchArguments = ["isRunningUITests"]
        app.launch()

        let timeout = 2.0
        let keyTextField = app.textFields["keyTextField"]
        let valueTextField = app.textFields["valueTextField"]

        XCTAssertTrue(keyTextField.waitForExistence(timeout: timeout))
        XCTAssertTrue(valueTextField.waitForExistence(timeout: timeout))



    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
