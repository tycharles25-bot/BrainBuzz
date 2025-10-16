//
//  UserProfile.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData
import Combine

@Model
final class UserProfile {
    var id: UUID
    var firstName: String
    var email: String
    var gender: String?
    var age: Int?
    var createdAt: Date
    
    init(firstName: String, email: String, gender: String? = nil, age: Int? = nil) {
        self.id = UUID()
        self.firstName = firstName
        self.email = email
        self.gender = gender
        self.age = age
        self.createdAt = Date()
    }
}
