//
//  NewQuizView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct NewQuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var quizTitle = ""
    @State private var textInput = ""
    @State private var showingManualCreation = false
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Create New Quiz")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Choose how you'd like to create your quiz")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // AI Generation Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            Text("AI Generation")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Text("Paste any text and AI will automatically create a quiz for you!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $textInput)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        
                        Button(action: generateQuizFromText) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                
                                Text(isGenerating ? "Generating..." : "Generate Quiz")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(textInput.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(textInput.isEmpty || isGenerating)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Manual Creation Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            Text("Manual Creation")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Text("Create your quiz manually with custom questions and answers.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingManualCreation = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Create Manually")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingManualCreation) {
            ManualQuizCreationView(quizTitle: $quizTitle)
        }
    }
    
    private func generateQuizFromText() {
        isGenerating = true
        
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            createQuizFromText()
            isGenerating = false
        }
    }
    
    private func createQuizFromText() {
        let title = extractTitleFromText() ?? "Generated Quiz"
        let newQuiz = Quiz(title: title)
        
        // Generate questions based on the text (simplified version)
        let questions = generateQuestionsFromText(textInput)
        
        for question in questions {
            question.quiz = newQuiz
            newQuiz.questions.append(question)
        }
        
        modelContext.insert(newQuiz)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving quiz: \(error)")
        }
    }
    
    private func extractTitleFromText() -> String? {
        let lines = textInput.components(separatedBy: .newlines)
        return lines.first?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func generateQuestionsFromText(_ text: String) -> [Question] {
        // Simplified question generation based on text content
        var questions: [Question] = []
        
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        for (index, sentence) in sentences.enumerated() {
            if index >= 5 { break } // Limit to 5 questions
            
            if sentence.contains("is") || sentence.contains("are") {
                // Create true/false question
                let question = Question(
                    text: sentence,
                    type: .trueFalse,
                    options: ["True", "False"],
                    correctAnswer: 0
                )
                questions.append(question)
            } else {
                // Create multiple choice question
                let options = ["Option A", "Option B", "Option C", "Option D"]
                let question = Question(
                    text: sentence + "?",
                    type: .multipleChoice,
                    options: options,
                    correctAnswer: 0
                )
                questions.append(question)
            }
        }
        
        return questions
    }
}

#Preview {
    NewQuizView()
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self], inMemory: true)
}
