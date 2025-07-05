//
//  Item.swift
//  Menu Bar Notes
//
//  Created by Jake Gibbons on 05/07/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
