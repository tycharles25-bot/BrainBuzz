//
//  ContentView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var userSession: UserSession
    @State private var selectedTab = 1 // Start with Dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryView()
                .tabItem {
                    Image(systemName: "wrench.and.screwdriver.fill")
                    Text("Tools")
                }
                .tag(0)
            
            DashboardView()
                .tabItem {
                    Image(systemName: "bolt")
                    Text("Dashboard")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .onAppear {
            setupInitialData()
        }
    }
    
    private func setupInitialData() {
        // Add demo quiz if none exist
        let fetchDescriptor = FetchDescriptor<Quiz>()
        let existingQuizzes = (try? modelContext.fetch(fetchDescriptor)) ?? []
        
        if existingQuizzes.isEmpty {
            createDemoQuiz()
        }
        
        // Add some motivation quotes
        let motivationFetch = FetchDescriptor<MotivationQuote>()
        let existingQuotes = (try? modelContext.fetch(motivationFetch)) ?? []
        
        if existingQuotes.isEmpty {
            createSampleQuotes()
        }
    }
    
    private func createDemoQuiz() {
        let demoQuiz = Quiz(title: "Are you smarter than a fifth grader?", isDemo: true)
        
        let questions = [
            Question(text: "The capital of France is Paris.", type: .trueFalse, options: ["True", "False"], correctAnswer: 0),
            Question(text: "What is 2 + 2?", type: .multipleChoice, options: ["3", "4", "5", "6"], correctAnswer: 1),
            Question(text: "The sun rises in the west.", type: .trueFalse, options: ["True", "False"], correctAnswer: 1),
            Question(text: "Which planet is closest to the sun?", type: .multipleChoice, options: ["Venus", "Mercury", "Earth", "Mars"], correctAnswer: 1),
            Question(text: "Water boils at 100 degrees Celsius.", type: .trueFalse, options: ["True", "False"], correctAnswer: 0)
        ]
        
        for question in questions {
            question.quiz = demoQuiz
            demoQuiz.questions.append(question)
        }
        
        modelContext.insert(demoQuiz)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving demo quiz: \(error)")
        }
    }
    
    private func createSampleQuotes() {
        let quotes = [
            MotivationQuote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
            MotivationQuote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill"),
            MotivationQuote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
            MotivationQuote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
            MotivationQuote(text: "It is during our darkest moments that we must focus to see the light.", author: "Aristotle")
        ]
        
        for quote in quotes {
            modelContext.insert(quote)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving quotes: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self, UserProfile.self], inMemory: true)
}
