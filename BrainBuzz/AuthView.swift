//
//  AuthView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI

struct AuthView: View {
    @State private var selectedTab: AuthTab = .signUp
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    let onComplete: (String) -> Void
    
    enum AuthTab: String, CaseIterable {
        case signUp = "Sign Up"
        case login = "Login"
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 60)
                    
                    Text("BrainBuzz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("Your Personal Learning Companion")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                        .frame(height: 40)
                }
                
                // Tabs
                HStack(spacing: 0) {
                    ForEach(AuthTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            Text(tab.rawValue)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedTab == tab ? .black : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                }
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary.opacity(0.3)),
                    alignment: .bottom
                )
                
                // Content
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Form Title
                    VStack(spacing: 8) {
                        Text(selectedTab == .signUp ? "Create Account" : "Welcome Back")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text(selectedTab == .signUp ? "Join BrainBuzz and start your learning journey" : "Sign in to continue your learning journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Confirm Password (Sign Up only)
                        if selectedTab == .signUp {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                SecureField("Confirm your password", text: $confirmPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Action Button
                    Button(action: {
                        handleAuth()
                    }) {
                        Text(selectedTab == .signUp ? "Create Account" : "Login")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var isFormValid: Bool {
        if selectedTab == .signUp {
            return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func handleAuth() {
        // For now, just proceed to onboarding with email
        // In a real app, you would handle authentication here
        onComplete(email)
    }
}

#Preview {
    AuthView { email in
        print("Auth complete with email: \(email)")
    }
}
