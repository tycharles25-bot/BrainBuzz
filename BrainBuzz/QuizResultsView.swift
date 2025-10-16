//
//  QuizResultsView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI

struct QuizResultsView: View {
    let quiz: Quiz
    let answers: [Int]
    let timeUsed: Int
    @Environment(\.dismiss) private var dismiss
    
    var score: Int {
        var correctAnswers = 0
        for (index, question) in quiz.questions.enumerated() {
            if index < answers.count && answers[index] == question.correctAnswer {
                correctAnswers += 1
            }
        }
        return correctAnswers
    }
    
    var percentage: Double {
        guard quiz.questions.count > 0 else { return 0 }
        return Double(score) / Double(quiz.questions.count) * 100
    }
    
    var performanceMessage: String {
        switch percentage {
        case 90...100:
            return "Excellent work! 🎉"
        case 80..<90:
            return "Great job! 👏"
        case 70..<80:
            return "Good effort! 👍"
        case 60..<70:
            return "Not bad! Keep practicing! 💪"
        default:
            return "Keep studying! You'll get there! 📚"
        }
    }
    
    var performanceColor: Color {
        switch percentage {
        case 90...100:
            return .green
        case 80..<90:
            return .blue
        case 70..<80:
            return .orange
        default:
            return .red
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Quiz Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(quiz.title)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Score Circle
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                                .frame(width: 150, height: 150)
                            
                            Circle()
                                .trim(from: 0, to: percentage / 100)
                                .stroke(
                                    performanceColor,
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 150, height: 150)
                                .rotationEffect(.degrees(-90))
                            
                            VStack {
                                Text("\(score)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(performanceColor)
                                
                                Text("of \(quiz.questions.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text(performanceMessage)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(performanceColor)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Statistics
                    VStack(spacing: 16) {
                        HStack {
                            StatisticCard(
                                title: "Accuracy",
                                value: String(format: "%.0f%%", percentage),
                                icon: "target"
                            )
                            
                            StatisticCard(
                                title: "Time",
                                value: formatTime(timeUsed),
                                icon: "clock"
                            )
                        }
                        
                        StatisticCard(
                            title: "Score",
                            value: "\(score)/\(quiz.questions.count)",
                            icon: "checkmark.circle"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Question Review
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Question Review")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(quiz.questions.indices, id: \.self) { index in
                                QuestionReviewCard(
                                    question: quiz.questions[index],
                                    userAnswer: index < answers.count ? answers[index] : -1,
                                    questionNumber: index + 1
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct QuestionReviewCard: View {
    let question: Question
    let userAnswer: Int
    let questionNumber: Int
    
    var isCorrect: Bool {
        userAnswer == question.correctAnswer
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Q\(questionNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isCorrect ? Color.green : Color.red)
                    .cornerRadius(4)
                
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                
                Spacer()
            }
            
            Text(question.text)
                .font(.subheadline)
                .fontWeight(.medium)
            
            if question.type == .multipleChoice {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(question.options.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(question.options[index])
                                .font(.caption)
                                .foregroundColor(
                                    index == question.correctAnswer ? .green :
                                    index == userAnswer ? .red : .primary
                                )
                            
                            if index == question.correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            if index == userAnswer && !isCorrect {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            
                            Spacer()
                        }
                    }
                }
            } else {
                HStack {
                    Text("Your answer:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(userAnswer == 0 ? "True" : "False")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                    
                    Text("Correct:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(question.correctAnswer == 0 ? "True" : "False")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    let demoQuiz = Quiz(title: "Demo Quiz")
    let question = Question(text: "What is 2 + 2?", type: .multipleChoice, options: ["3", "4", "5", "6"], correctAnswer: 1)
    question.quiz = demoQuiz
    demoQuiz.questions.append(question)
    
    return QuizResultsView(quiz: demoQuiz, answers: [1], timeUsed: 120)
}
