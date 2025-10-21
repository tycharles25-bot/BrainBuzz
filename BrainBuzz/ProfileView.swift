//
//  ProfileView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var userSession: UserSession
    @Query private var quizResults: [QuizResult]
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Picture
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        // User Info
                        VStack(spacing: 4) {
                            Text(userSession.currentUser?.firstName ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(userSession.currentUser?.email ?? "No email")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Settings Button
                        Button("Settings") {
                            // Settings action
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                    .padding(.top, 20)
                    
                    
                    // Menu Items
                    VStack(spacing: 0) {
                        MenuRow(
                            icon: "globe",
                            title: "Language",
                            showArrow: false
                        )
                        
                        MenuRow(
                            icon: "crown",
                            title: "Upgrade to Premium",
                            showArrow: true
                        )
                        
                        MenuRow(
                            icon: "gift",
                            title: "Claim Free Trial",
                            showArrow: false
                        )
                        
                        MenuRow(
                            icon: "envelope",
                            title: "Contact Us",
                            showArrow: false
                        )
                        
                        MenuRow(
                            icon: "doc.text",
                            title: "Terms of Use",
                            showArrow: false
                        )
                        
                        MenuRow(
                            icon: "lock",
                            title: "Privacy Policy",
                            showArrow: false
                        )
                        
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            MenuRow(
                                icon: "rectangle.portrait.and.arrow.right",
                                title: "Sign Out",
                                showArrow: true,
                                isDestructive: true
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100) // Space for tab bar
                }
            }
            .navigationBarHidden(true)
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    userSession.logout()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let showArrow: Bool
    var isDestructive: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isDestructive ? .red : .primary)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(isDestructive ? .red : .primary)
            
            Spacer()
            
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.clear)
        
        if showArrow || isDestructive {
            Divider()
                .padding(.leading, 40)
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self], inMemory: true)
}
