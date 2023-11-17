//
//  SharedListsUITests.swift
//  SharedListsUITests
//
//  Created by Vadim Zhuk on 14/11/2023.
//

import XCTest

final class SharedListsUITests: XCTestCase {

    var app = XCUIApplication()

    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false
        setupSnapshot(app)
        app.launchEnvironment = [ "RUNNING_UI_TESTS": "YES" ]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppstoreScreenShots() throws {
        
        let app = XCUIApplication()
        app.collectionViews.containing(.other, identifier:"Vertical scroll bar, 1 page").element.tap()
        app.collectionViews.buttons.firstMatch.waitForExistence(timeout: 3)
        snapshot("List of lists")
        app.collectionViews.buttons.firstMatch.tap()
        snapshot("List details")
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
