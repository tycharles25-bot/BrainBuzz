//
//  HistoryView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Quiz.createdAt, order: .reverse) private var quizzes: [Quiz]
    
    var body: some View {
        NavigationView {
            VStack {
                if quizzes.isEmpty {
                    // Empty State
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 80))
                            .foregroundColor(.secondary)
                        
                        Text("No Quiz History")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Create some quizzes to see your history here!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    // History List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(quizzes.prefix(15)) { quiz in
                                QuizHistoryCard(quiz: quiz)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationTitle("Quiz History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuizHistoryCard: View {
    let quiz: Quiz
    @State private var showingQuiz = false
    
    var body: some View {
        Button(action: {
            showingQuiz = true
        }) {
            HStack(spacing: 16) {
                // Quiz Icon
                Image(systemName: "doc.text")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                
                // Quiz Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(quiz.createdAt, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(quiz.questions.count) questions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingQuiz) {
            QuizTakingView(quiz: quiz)
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self], inMemory: true)
}
