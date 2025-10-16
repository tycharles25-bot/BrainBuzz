//
//  Item.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
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
