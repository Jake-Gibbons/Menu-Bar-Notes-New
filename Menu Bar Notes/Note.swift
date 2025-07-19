//
//  Note.swift
//  Menu Bar Notes
//
//  Created by Jake Gibbons on 05/07/2025.
//

import Foundation
import SwiftData

@Model
final class Note {
    var text: String

    init(text: String = "") {
        self.text = text
    }
}
