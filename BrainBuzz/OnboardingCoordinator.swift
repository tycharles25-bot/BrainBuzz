//
//  OnboardingCoordinator.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct OnboardingCoordinator: View {
    @State private var currentStep = 0
    @State private var userData = UserData()
    @Environment(\.modelContext) private var modelContext
    let email: String
    let onComplete: (UserProfile) -> Void
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            switch currentStep {
            case 0:
                OnboardingNameView { name in
                    userData.firstName = name
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = 1
                    }
                }
            case 1:
                OnboardingGenderView { gender in
                    userData.gender = gender
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = 2
                    }
                }
            case 2:
                OnboardingAgeView { age in
                    userData.age = age
                    createUserProfile()
                }
            default:
                OnboardingNameView { name in
                    userData.firstName = name
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = 1
                    }
                }
            }
        }
    }
    
    private func createUserProfile() {
        let userProfile = UserProfile(
            firstName: userData.firstName,
            email: email,
            gender: userData.gender?.rawValue,
            age: userData.age
        )
        
        // Save to SwiftData
        modelContext.insert(userProfile)
        
        // Complete onboarding
        onComplete(userProfile)
    }
}

struct UserData {
    var firstName: String = ""
    var gender: OnboardingGenderView.GenderOption?
    var age: Int = 0
}

#Preview {
    OnboardingCoordinator(email: "test@example.com") { userProfile in
        print("Onboarding complete: \(userProfile)")
    }
}
