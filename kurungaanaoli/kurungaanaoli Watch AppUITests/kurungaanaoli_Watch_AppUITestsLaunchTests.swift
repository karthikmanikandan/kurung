//
//  kurungaanaoli_Watch_AppUITestsLaunchTests.swift
//  kurungaanaoli Watch AppUITests
//
//  Created by 𑀓𑀸𑀭𑁆𑀢𑁆𑀢𑀺𑀓𑁆 𑀫𑀡𑀺𑀓𑀡𑁆𑀝𑀷𑁆 on 25/07/25.
//

import XCTest

final class kurungaanaoli_Watch_AppUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
