//
//  SwiftDataDebugAppTests.swift
//  SwiftDataDebugAppTests
//
//  Created by Stef Kors on 04/03/2024.
//

import XCTest
import SwiftData
@testable import SwiftDataDebugApp

@MainActor
final class SwiftDataDebugAppTests: XCTestCase {
    let simpleVersionBump: String = """
diff --git a/package.json b/package.json
index 09ff520..4f245a9 100644
--- a/package.json
+++ b/package.json
@@ -1,6 +1,6 @@
 {
   "name": "playground",
-  "version": "2.0.0",
+  "version": "2.0.1",
   "main": "index.js",
   "license": "MIT",
   "dependencies": {
"""

    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GitDiff.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()


    // We want to check if the first line character is correctly removed.
    // That's where the `+` or `-` or ` ` (unchanged) is and we will parse that to a specific type.
    func testSimpleVersionBump() throws {
        let context = sharedModelContainer.mainContext

        let parsingResults = GitDiffParserParse(unifiedDiff: simpleVersionBump)

        let output = GitDiff.init(
            addedFile: parsingResults.addedFile,
            removedFile: parsingResults.removedFile,
            hunks: parsingResults.hunks,
            unifiedDiff: simpleVersionBump
        )

        let firstHunk = output.hunks.first
        let firstLine = firstHunk?.lines.first

        XCTAssertEqual(output.hunks.count, 1)
        XCTAssertEqual(firstLine?.type, .context)
        guard let text = firstLine?.text else {
            XCTFail("expected text on first line of diff")
            return
        }

        XCTAssertEqual(text, "{")
    }

}
