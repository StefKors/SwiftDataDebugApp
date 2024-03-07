//
//  Item.swift
//  SwiftDataDebugApp
//
//  Created by Stef Kors on 04/03/2024.
//

import Foundation
import SwiftData

/// Represents a universal git diff
@Model final class GitDiff {
    var status: GitFileStatus? = nil

    var addedFile: String = ""

    var removedFile: String = ""

    @Relationship(deleteRule: .cascade, inverse: \GitDiffHunk.diff)
    var hunks = [GitDiffHunk]()

    // Source string of diff
    let unifiedDiff: String = ""

    init(status: GitFileStatus? = nil, addedFile: String = "", removedFile: String = "", hunks: [GitDiffHunk] = [], unifiedDiff: String = "") {
        self.status = status
        self.addedFile = addedFile
        self.removedFile = removedFile
        self.hunks = hunks
        self.unifiedDiff = unifiedDiff
    }
}

@Model final class GitFileStatus {
    var path: String

    @Relationship(deleteRule: .cascade, inverse: \GitDiff.status)
    var diff: GitDiff? = nil

    init(path: String) {
        self.path = path
    }
}


@Model final class GitDiffHunk {
    var oldLineStart: Int = 0

    var oldLineSpan: Int = 0

    var newLineStart: Int = 0

    var newLineSpan: Int = 0

    var numOfDeletions: Int = 0

    var numOfAdditions: Int = 0

    var numOfContextBefore: Int = 0

    var numOfContextAfter: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \GitDiffHunkLine.hunk)
    var lines = [GitDiffHunkLine]()

    var diff: GitDiff?

    var header: String = ""

    init(oldLineStart: Int, oldLineSpan: Int, newLineStart: Int, newLineSpan: Int, numOfDeletions: Int, numOfAdditions: Int, numOfContextBefore: Int, numOfContextAfter: Int, header: String) {
        self.oldLineStart = oldLineStart
        self.oldLineSpan = oldLineSpan
        self.newLineStart = newLineStart
        self.newLineSpan = newLineSpan
        self.numOfDeletions = numOfDeletions
        self.numOfAdditions = numOfAdditions
        self.numOfContextBefore = numOfContextBefore
        self.numOfContextAfter = numOfContextAfter
        self.header = header
    }
}

@Model class GitDiffHunkLine {
    var type: GitDiffHunkLineType

    var text: String

    var oldLineNumber: Int?

    var newLineNumber: Int?

    var hunk: GitDiffHunk?

    init(type: GitDiffHunkLineType, text: String, oldLineNumber: Int? = nil, newLineNumber: Int? = nil) {
        self.type = type
        self.text = text
        self.oldLineNumber = oldLineNumber
        self.newLineNumber = newLineNumber
    }
}

/// Types of lines inside a hunk.
enum GitDiffHunkLineType: String, CaseIterable, Codable {
    case context = "context"
    case addition = "addition"
    case deletion = "deletion"
}
