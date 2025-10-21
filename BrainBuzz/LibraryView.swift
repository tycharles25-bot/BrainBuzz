//
//  LibraryView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingStatistics = false
    @State private var showingMotivation = false
    @State private var showingHistory = false
    @State private var showingQuizOfTheDay = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Tools")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Feature Cards List
                    VStack(spacing: 20) {
                        // Statistics Card
                        FeatureCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Statistics",
                            color: .green
                        ) {
                            showingStatistics = true
                        }
                        
                        // Bracelet Card
                        FeatureCard(
                            icon: "applewatch",
                            title: "Bracelet",
                            color: .purple
                        ) {
                            // Placeholder for bracelet functionality
                        }
                        
                        // Motivation Card
                        FeatureCard(
                            icon: "lightbulb",
                            title: "Motivation",
                            color: .orange
                        ) {
                            showingMotivation = true
                        }
                        
                        // History Card
                        FeatureCard(
                            icon: "clock.arrow.circlepath",
                            title: "History",
                            color: .blue
                        ) {
                            showingHistory = true
                        }
                        
                        // Quiz of the Day Card
                        FeatureCard(
                            icon: "calendar",
                            title: "Quiz of the Day!",
                            color: .red
                        ) {
                            showingQuizOfTheDay = true
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    
                    Spacer(minLength: 50) // Space for tab bar
                }
                }
                .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView()
        }
        .sheet(isPresented: $showingMotivation) {
            MotivationView()
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
        }
        .sheet(isPresented: $showingQuizOfTheDay) {
            QuizOfTheDayView()
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.black)
                    .frame(width: 60, height: 60)
                
                // Title
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 80)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LibraryView()
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self], inMemory: true)
}
