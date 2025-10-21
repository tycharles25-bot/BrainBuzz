//
//  DashboardView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var userSession: UserSession
    @Query private var quizzes: [Quiz]
    @Query private var quizResults: [QuizResult]
    @State private var showingNewQuiz = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                    // Welcome Header
                    HStack {
                        Text(userSession.currentUser?.firstName != nil ? "Welcome, \(userSession.currentUser!.firstName)!" : "Welcome!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // New Quiz Button
                    Button(action: {
                        showingNewQuiz = true
                    }) {
                        VStack(spacing: 16) {
                            Image(systemName: "plus")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                            
                            Text("New Quiz")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200) // Fixed height that works on all devices
                        .background(Color.black)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    
                    // Recent Activity Section
                    if !quizzes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Quizzes")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ForEach(quizzes.prefix(3)) { quiz in
                                QuizPreviewCard(quiz: quiz)
                            }
                        }
                        .padding(.top)
                    }
                    
                    Spacer(minLength: 100) // Space for tab bar
                }
                }
                .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showingNewQuiz) {
            NewQuizView()
        }
    }
}


struct QuizPreviewCard: View {
    let quiz: Quiz
    @State private var showingQuiz = false
    
    var body: some View {
        Button(action: {
            showingQuiz = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text("\(quiz.questions.count) questions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(quiz.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingQuiz) {
            QuizTakingView(quiz: quiz)
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self], inMemory: true)
}
