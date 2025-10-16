//
//  QuizTakingView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct QuizTakingView: View {
    let quiz: Quiz
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var answers: [Int] = []
    @State private var showingResults = false
    @State private var timeRemaining = 300 // 5 minutes in seconds
    @State private var timer: Timer?
    
    // Safety pop-up states
    @State private var consecutiveWrongAnswers = 0
    @State private var showingTakeBreakAlert = false
    
    // Answer feedback states
    @State private var showingFeedback = false
    @State private var isLastAnswerCorrect = false
    @State private var showingAnswerResult = false
    
    var currentQuestion: Question {
        quiz.questions[currentQuestionIndex]
    }
    
    var progress: Double {
        Double(currentQuestionIndex) / Double(quiz.questions.count)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .black))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                // Question counter (timer only for Quiz of the Day)
                HStack {
                    if quiz.title.contains("Quiz of the Day") {
                        Text("Time: \(formatTime(timeRemaining))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("")
                            .font(.caption)
                    }
                    Spacer()
                    Text("Question \(currentQuestionIndex + 1) of \(quiz.questions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Question Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Question Text
                        VStack(alignment: .leading, spacing: 16) {
                            Text(currentQuestion.text)
                                .font(.title2)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Answer Options
                        VStack(spacing: 12) {
                            if currentQuestion.type == .trueFalse {
                                TrueFalseAnswerView(
                                    selectedAnswer: $selectedAnswer,
                                    correctAnswer: currentQuestion.correctAnswer,
                                    showingResult: showingAnswerResult,
                                    isCorrect: isLastAnswerCorrect,
                                    onAnswerSelected: handleAnswerSelection
                                )
                            } else {
                                MultipleChoiceAnswerView(
                                    options: currentQuestion.options,
                                    selectedAnswer: $selectedAnswer,
                                    correctAnswer: currentQuestion.correctAnswer,
                                    showingResult: showingAnswerResult,
                                    isCorrect: isLastAnswerCorrect,
                                    onAnswerSelected: handleAnswerSelection
                                )
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
                
                // Auto-advance after answer selection
                // Navigation buttons removed - answers are final
            }
            .navigationTitle(quiz.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if quiz.title.contains("Quiz of the Day") {
                    startTimer()
                }
                initializeAnswers()
            }
            .onDisappear {
                timer?.invalidate()
            }
        .sheet(isPresented: $showingResults) {
            QuizResultsView(
                quiz: quiz,
                answers: answers,
                timeUsed: quiz.title.contains("Quiz of the Day") ? (300 - timeRemaining) : 0
            )
        }
        .alert("Maybe it's time to take a break", isPresented: $showingTakeBreakAlert) {
            Button("Keep Going") {
                handleKeepGoing()
            }
            Button("Quit Quiz", role: .destructive) {
                handleQuitQuiz()
            }
        } message: {
            Text("You've gotten 3 questions wrong in a row. Consider taking a break or you can continue if you'd like.")
        }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                finishQuiz()
            }
        }
    }
    
    private func initializeAnswers() {
        answers = Array(repeating: -1, count: quiz.questions.count)
    }
    
    private func goToPreviousQuestion() {
        currentQuestionIndex -= 1
        selectedAnswer = answers[currentQuestionIndex] >= 0 ? answers[currentQuestionIndex] : nil
        showingAnswerResult = false
    }
    
    private func goToNextQuestion() {
        currentQuestionIndex += 1
        selectedAnswer = answers[currentQuestionIndex] >= 0 ? answers[currentQuestionIndex] : nil
        showingAnswerResult = false
    }
    
    
    private func finishQuiz() {
        if quiz.title.contains("Quiz of the Day") {
            timer?.invalidate()
        }
        
        let score = calculateScore()
        let result = QuizResult(
            quiz: quiz,
            score: score,
            totalQuestions: quiz.questions.count,
            answers: answers
        )
        
        modelContext.insert(result)
        
        do {
            try modelContext.save()
            showingResults = true
        } catch {
            print("Error saving quiz result: \(error)")
        }
    }
    
    private func calculateScore() -> Int {
        var score = 0
        for (index, question) in quiz.questions.enumerated() {
            if index < answers.count && answers[index] == question.correctAnswer {
                score += 1
            }
        }
        return score
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    
    private func showTakeBreakAlert() {
        showingTakeBreakAlert = true
    }
    
    private func handleKeepGoing() {
        showingTakeBreakAlert = false
        consecutiveWrongAnswers = 0 // Reset counter
    }
    
    private func handleQuitQuiz() {
        showingTakeBreakAlert = false
        finishQuiz()
    }
    
    private func showAnswerFeedback() {
        showingFeedback = true
        
        // Auto-dismiss feedback after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingFeedback = false
        }
    }
    
    private func handleAnswerSelection(answer: Int) {
        // Save the answer
        answers[currentQuestionIndex] = answer
        
        // Check if answer is correct or wrong
        let isCorrect = answer == currentQuestion.correctAnswer
        isLastAnswerCorrect = isCorrect
        
        if isCorrect {
            // Reset consecutive wrong answers counter
            consecutiveWrongAnswers = 0
        } else {
            // Increment consecutive wrong answers
            consecutiveWrongAnswers += 1
            
            // Show safety pop-up after 3 consecutive wrong answers
            if consecutiveWrongAnswers == 3 {
                showTakeBreakAlert()
            }
        }
        
        // Show feedback by coloring the answer
        showingAnswerResult = true
        showingFeedback = true
        
        // Auto-advance after showing feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentQuestionIndex < quiz.questions.count - 1 {
                goToNextQuestion()
            } else {
                finishQuiz()
            }
        }
    }
}

struct TrueFalseAnswerView: View {
    @Binding var selectedAnswer: Int?
    let correctAnswer: Int
    let showingResult: Bool
    let isCorrect: Bool
    let onAnswerSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                selectedAnswer = 0
                onAnswerSelected(0)
            }) {
                HStack {
                    Image(systemName: selectedAnswer == 0 ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(selectedAnswer == 0 ? .black : .gray)
                    
                    Text("True")
                        .font(.title3)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding()
                .background(
                    showingResult && selectedAnswer == 0 ? 
                    (isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) :
                    (selectedAnswer == 0 ? Color.black.opacity(0.1) : Color(.systemGray6))
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            showingResult && selectedAnswer == 0 ? 
                            (isCorrect ? Color.green : Color.red) :
                            (selectedAnswer == 0 ? Color.black : Color.clear), 
                            lineWidth: 2
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(showingResult)
            
            Button(action: {
                selectedAnswer = 1
                onAnswerSelected(1)
            }) {
                HStack {
                    Image(systemName: selectedAnswer == 1 ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(selectedAnswer == 1 ? .black : .gray)
                    
                    Text("False")
                        .font(.title3)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding()
                .background(
                    showingResult && selectedAnswer == 1 ? 
                    (isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) :
                    (selectedAnswer == 1 ? Color.black.opacity(0.1) : Color(.systemGray6))
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            showingResult && selectedAnswer == 1 ? 
                            (isCorrect ? Color.green : Color.red) :
                            (selectedAnswer == 1 ? Color.black : Color.clear), 
                            lineWidth: 2
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(showingResult)
        }
    }
}

struct MultipleChoiceAnswerView: View {
    let options: [String]
    @Binding var selectedAnswer: Int?
    let correctAnswer: Int
    let showingResult: Bool
    let isCorrect: Bool
    let onAnswerSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options.indices, id: \.self) { index in
                Button(action: {
                    selectedAnswer = index
                    onAnswerSelected(index)
                }) {
                    HStack {
                        Image(systemName: selectedAnswer == index ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(selectedAnswer == index ? .black : .gray)
                        
                        Text(options[index])
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        showingResult && selectedAnswer == index ? 
                        (isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) :
                        (selectedAnswer == index ? Color.black.opacity(0.1) : Color(.systemGray6))
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                showingResult && selectedAnswer == index ? 
                                (isCorrect ? Color.green : Color.red) :
                                (selectedAnswer == index ? Color.black : Color.clear), 
                                lineWidth: 2
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(showingResult)
            }
        }
    }
}

#Preview {
    let demoQuiz = Quiz(title: "Demo Quiz")
    let question = Question(text: "What is 2 + 2?", type: .multipleChoice, options: ["3", "4", "5", "6"], correctAnswer: 1)
    question.quiz = demoQuiz
    demoQuiz.questions.append(question)
    
    return QuizTakingView(quiz: demoQuiz)
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self], inMemory: true)
}
