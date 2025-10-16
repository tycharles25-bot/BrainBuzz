//
//  QuizOfTheDayView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct QuizOfTheDayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingQuiz = false
    @State private var todaysQuiz: Quiz?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let quiz = todaysQuiz {
                    // Quiz of the Day Display
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Today's Challenge")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(quiz.title)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Quiz Preview
                        VStack(spacing: 16) {
                            Image(systemName: "calendar")
                                .font(.system(size: 60))
                                .foregroundColor(.black)
                            
                            VStack(spacing: 8) {
                                Text("\(quiz.questions.count) Questions")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("Test your knowledge with today's featured quiz!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        // Start Button
                        Button(action: {
                            showingQuiz = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Text("Start Quiz")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    // No Quiz Available
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 80))
                            .foregroundColor(.secondary)
                        
                        Text("No Quiz Today")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Check back tomorrow for a new daily challenge!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Create Your Own Quiz") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Quiz of the Day!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            generateTodaysQuiz()
        }
        .sheet(isPresented: $showingQuiz) {
            if let quiz = todaysQuiz {
                QuizTakingView(quiz: quiz)
            }
        }
    }
    
    private func generateTodaysQuiz() {
        // Create a daily quiz based on the current date
        let calendar = Calendar.current
        let today = Date()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        
        let dailyQuizTitles = [
            "Daily Trivia Challenge",
            "Today's Brain Teaser",
            "Daily Knowledge Test",
            "Quick Brain Workout",
            "Today's Fun Facts",
            "Daily Memory Challenge"
        ]
        
        let title = dailyQuizTitles[dayOfYear % dailyQuizTitles.count]
        let quiz = Quiz(title: "\(title) - \(today.formatted(date: .abbreviated, time: .omitted))")
        
        // Generate questions based on the day
        let questions = generateDailyQuestions(dayOfYear: dayOfYear)
        
        for question in questions {
            question.quiz = quiz
            quiz.questions.append(question)
        }
        
        todaysQuiz = quiz
    }
    
    private func generateDailyQuestions(dayOfYear: Int) -> [Question] {
        var questions: [Question] = []
        
        // Generate 5 questions based on the day of year
        let questionSets = [
            // General Knowledge
            [
                Question(text: "The Earth has one natural satellite.", type: .trueFalse, options: ["True", "False"], correctAnswer: 0),
                Question(text: "What is the capital of Japan?", type: .multipleChoice, options: ["Seoul", "Tokyo", "Beijing", "Bangkok"], correctAnswer: 1),
                Question(text: "Water freezes at 32 degrees Fahrenheit.", type: .trueFalse, options: ["True", "False"], correctAnswer: 0),
                Question(text: "Which planet is known as the Red Planet?", type: .multipleChoice, options: ["Venus", "Mars", "Jupiter", "Saturn"], correctAnswer: 1),
                Question(text: "The Great Wall of China is visible from space with the naked eye.", type: .trueFalse, options: ["True", "False"], correctAnswer: 1)
            ],
            // Science
            [
                Question(text: "Photosynthesis produces oxygen.", type: .trueFalse, options: ["True", "False"], correctAnswer: 0),
                Question(text: "What is the chemical symbol for gold?", type: .multipleChoice, options: ["Go", "Gd", "Au", "Ag"], correctAnswer: 2),
                Question(text: "The human body has 206 bones.", type: .trueFalse, options: ["True", "False"], correctAnswer: 0),
                Question(text: "Which gas makes up most of Earth's atmosphere?", type: .multipleChoice, options: ["Oxygen", "Nitrogen", "Carbon Dioxide", "Hydrogen"], correctAnswer: 1),
                Question(text: "Light travels faster than sound.", type: .trueFalse, options: ["True", "False"], correctAnswer: 0)
            ],
            // History
            [
                Question(text: "The Great Pyramid was built in Egypt.", type: .trueFalse, options: ["True", "False"], correctAnswer: 0),
                Question(text: "Who painted the Mona Lisa?", type: .multipleChoice, options: ["Van Gogh", "Picasso", "Da Vinci", "Michelangelo"], correctAnswer: 2),
                Question(text: "The Berlin Wall fell in 1989.", type: .trueFalse, options: ["True", "False"], correctAnswer: 0),
                Question(text: "Which country hosted the first modern Olympics?", type: .multipleChoice, options: ["France", "Greece", "United Kingdom", "Germany"], correctAnswer: 1),
                Question(text: "The Renaissance began in Italy.", type: .trueFalse, options: ["True", "False"], correctAnswer: 0)
            ]
        ]
        
        let selectedSet = questionSets[dayOfYear % questionSets.count]
        questions = Array(selectedSet.prefix(5))
        
        return questions
    }
}

#Preview {
    QuizOfTheDayView()
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self], inMemory: true)
}
