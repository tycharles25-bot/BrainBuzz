//
//  AppCoordinator.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct AppCoordinator: View {
    @StateObject private var userSession = UserSession()
    @State private var currentScreen: AppScreen = .splash
    @State private var userEmail: String = ""
    @State private var userProfile: UserProfile?
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    enum AppScreen {
        case splash
        case auth
        case onboarding
        case main
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea(.all, edges: .all)
            
            switch currentScreen {
            case .splash:
                SplashScreenView {
                    checkUserSession()
                }
                .transition(.opacity)
                
            case .auth:
                AuthView { email in
                    self.userEmail = email
                    handleAuth(email: email)
                }
                .transition(.slide)
                
            case .onboarding:
                OnboardingCoordinator(email: userEmail) { userProfile in
                    self.userProfile = userProfile
                    userSession.login(email: userEmail, userProfile: userProfile)
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .main
                    }
                }
                .transition(.slide)
                
            case .main:
                ContentView()
                    .environmentObject(userSession)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .all)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: currentScreen)
        .onChange(of: userProfiles) { _, newProfiles in
            // Update current user if we have a saved email
            if let savedEmail = userSession.savedEmail,
               let matchingProfile = newProfiles.first(where: { $0.email == savedEmail }) {
                userSession.updateCurrentUser(matchingProfile)
            }
        }
        .onChange(of: userSession.isLoggedIn) { _, isLoggedIn in
            if !isLoggedIn {
                // User logged out, return to splash screen
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentScreen = .splash
                }
            }
        }
    }
    
    private func checkUserSession() {
        if userSession.isLoggedIn {
            // User is already logged in, go directly to main app
            withAnimation(.easeInOut(duration: 0.5)) {
                currentScreen = .main
            }
        } else {
            // User needs to login
            withAnimation(.easeInOut(duration: 0.5)) {
                currentScreen = .auth
            }
        }
    }
    
    private func handleAuth(email: String) {
        // Check if user already exists in database
        if let existingUser = userProfiles.first(where: { $0.email == email }) {
            // User exists, login directly
            userSession.login(email: email, userProfile: existingUser)
            withAnimation(.easeInOut(duration: 0.5)) {
                currentScreen = .main
            }
        } else {
            // New user, go through onboarding
            withAnimation(.easeInOut(duration: 0.5)) {
                currentScreen = .onboarding
            }
        }
    }
}

#Preview {
    AppCoordinator()
}
