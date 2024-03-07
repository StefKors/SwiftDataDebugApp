//
//  ContentView.swift
//  SwiftDataDebugApp
//
//  Created by Stef Kors on 04/03/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var diffs: [GitDiff]

    private let explainer: String = """
Hi there,

This is an demo project that parses a git diff string into a SwiftData representation. When assigning a value to a SwiftData relationship it crashes. There is almost no debug information available about what causes the crash in SwiftData or how to resolve it.

Press the button below to trigger the crash, or checkout `SwiftDataDebugAppTests.swift` for a unit test

Tested on:
- `Xcode Version 15.3 (15E5202a)`
- MacBook Pro 14 M2 Pro
- Sonoma 14.3 (23D56)
"""

    private let simpleVersionBump: String = """
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

    var body: some View {
        VStack {
            GroupBox {
                Text(explainer)


            }
            Button("Parse diff & Crash") {
                parse()
            }

            List(diffs) { diff in
                GroupBox("diff") {
                    VStack(alignment: .leading) {
                        Text(diff.addedFile)
                        Text(diff.hunks.debugDescription)

                        ForEach(diff.hunks) { hunk in
                            GroupBox("hunk") {
                                Text(hunk.header)

                                ForEach(hunk.lines) { line in
                                    GroupBox("line") {
                                        HStack {
                                            Text(line.type.rawValue)
                                            Text(line.oldLineNumber?.description ?? "nil")
                                            Text(line.newLineNumber?.description ?? "nil")
                                            Text(line.text)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }

                }.contextMenu(ContextMenu(menuItems: {
                    Button("Delete", role: .destructive) {
                        withAnimation {
                            modelContext.delete(diff)
                        }
                    }
                }))
            }
        }
    }

    private func parse() {
        let parsingResults = GitDiffParserParse(unifiedDiff: simpleVersionBump)

        let output = GitDiff.init(
            addedFile: parsingResults.addedFile,
            removedFile: parsingResults.removedFile,
            hunks: parsingResults.hunks,
            unifiedDiff: simpleVersionBump
        )


        let firstHunk = output.hunks.first // Crash
        let firstLine = firstHunk?.lines.first

        print(firstHunk)
        print(firstLine)

        withAnimation {
            modelContext.insert(output)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GitDiff.self, inMemory: true)
}
