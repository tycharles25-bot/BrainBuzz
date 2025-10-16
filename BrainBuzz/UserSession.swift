//
//  UserSession.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData
import Combine

class UserSession: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: UserProfile?
    
    private let userDefaults = UserDefaults.standard
    private let userEmailKey = "saved_user_email"
    
    init() {
        checkForExistingUser()
    }
    
    func checkForExistingUser() {
        // Check if we have a saved email
        if let savedEmail = userDefaults.string(forKey: userEmailKey), !savedEmail.isEmpty {
            isLoggedIn = true
            // The currentUser will be set when we fetch from SwiftData
        }
    }
    
    func login(email: String, userProfile: UserProfile? = nil) {
        // Save email to UserDefaults
        userDefaults.set(email, forKey: userEmailKey)
        
        // Set current user if provided
        if let profile = userProfile {
            currentUser = profile
        }
        
        isLoggedIn = true
    }
    
    func logout() {
        // Clear saved email
        userDefaults.removeObject(forKey: userEmailKey)
        
        // Clear current user
        currentUser = nil
        isLoggedIn = false
    }
    
    func updateCurrentUser(_ user: UserProfile) {
        currentUser = user
    }
    
    var savedEmail: String? {
        return userDefaults.string(forKey: userEmailKey)
    }
}
