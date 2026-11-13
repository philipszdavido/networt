//
//  networtUITests.swift
//  networtUITests
//
//  Created by Chidume Nnamdi on 4/3/24.
//

import XCTest

final class networtUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func enterPin(_ pin: String, in app: XCUIApplication) {
        for digit in pin {
            app.buttons[String(digit)].tap()
        }
    }

    func snapshot(_ name: String, _ app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Expects a fresh install (no PIN in the Keychain). Needs network access for currency rates.
    func testFirstRunAddAccountAndRelaunchLocks() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 10))
        snapshot("01-onboarding", app)
        app.buttons["Continue"].tap()

        XCTAssertTrue(app.staticTexts["Create a PIN"].waitForExistence(timeout: 5))
        snapshot("02-create-pin", app)
        enterPin("1234", in: app)
        XCTAssertTrue(app.staticTexts["Confirm your PIN"].waitForExistence(timeout: 5))
        enterPin("1234", in: app)

        // Empty Home, then add a bank account through the form.
        XCTAssertTrue(app.buttons["Add account"].waitForExistence(timeout: 30))
        snapshot("03-home-empty", app)
        app.buttons["Add account"].tap()

        let name = app.textFields["Bank name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Chase")
        let balance = app.textFields["0.00"]
        balance.tap()
        balance.typeText("2500.75")
        snapshot("04-add-bank", app)
        app.buttons["Save"].tap()

        XCTAssertTrue(app.staticTexts["Net worth"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Bank"].exists)
        snapshot("05-home", app)

        app.tabBars.buttons["Accounts"].tap()
        XCTAssertTrue(app.staticTexts["Chase"].waitForExistence(timeout: 5))
        snapshot("06-accounts", app)
        app.staticTexts["Chase"].tap()
        XCTAssertTrue(app.buttons["Add money"].waitForExistence(timeout: 5))
        snapshot("07-bank-detail", app)

        app.tabBars.buttons["Plan"].tap()
        XCTAssertTrue(app.staticTexts["Goals"].waitForExistence(timeout: 5))
        snapshot("08-plan", app)

        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Main currency"].waitForExistence(timeout: 5))
        snapshot("09-settings", app)

        // Relaunching must ask for the PIN again; a wrong PIN keeps it locked.
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["Enter PIN"].waitForExistence(timeout: 10))
        enterPin("0000", in: app)
        XCTAssertTrue(app.staticTexts["Incorrect PIN. Try again."].waitForExistence(timeout: 3))
        snapshot("10-lock-wrong-pin", app)
        enterPin("1234", in: app)
        XCTAssertTrue(app.staticTexts["Net worth"].waitForExistence(timeout: 10))
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
