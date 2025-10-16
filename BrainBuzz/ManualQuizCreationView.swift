//
//  ManualQuizCreationView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct ManualQuizCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Binding var quizTitle: String
    @State private var questions: [QuestionBuilder] = []
    @State private var showingQuestionEditor = false
    @State private var editingQuestionIndex: Int?
    
    var body: some View {
        NavigationView {
            VStack {
                // Quiz Title Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quiz Title")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("Enter quiz title", text: $quizTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Questions Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Questions (\(questions.count)/15)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: {
                            editingQuestionIndex = questions.count
                            showingQuestionEditor = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .disabled(questions.count >= 15)
                    }
                    .padding(.horizontal)
                    
                    if questions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("No questions yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Tap the + button to add your first question")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(questions.indices, id: \.self) { index in
                                    QuestionPreviewCard(
                                        question: questions[index],
                                        index: index + 1,
                                        onEdit: {
                                            editingQuestionIndex = index
                                            showingQuestionEditor = true
                                        },
                                        onDelete: {
                                            questions.remove(at: index)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // Save Button
                Button(action: saveQuiz) {
                    Text("Save Quiz")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(quizTitle.isEmpty || questions.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(quizTitle.isEmpty || questions.isEmpty)
                .padding()
            }
            .navigationTitle("Create Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingQuestionEditor) {
            QuestionEditorView(
                question: editingQuestionIndex != nil && editingQuestionIndex! < questions.count 
                    ? questions[editingQuestionIndex!] 
                    : QuestionBuilder(),
                onSave: { question in
                    if let index = editingQuestionIndex {
                        if index < questions.count {
                            questions[index] = question
                        } else {
                            questions.append(question)
                        }
                    } else {
                        questions.append(question)
                    }
                    editingQuestionIndex = nil
                    showingQuestionEditor = false
                },
                onCancel: {
                    editingQuestionIndex = nil
                    showingQuestionEditor = false
                }
            )
        }
    }
    
    private func saveQuiz() {
        let newQuiz = Quiz(title: quizTitle)
        
        for questionBuilder in questions {
            let question = Question(
                text: questionBuilder.text,
                type: questionBuilder.type,
                options: questionBuilder.options,
                correctAnswer: questionBuilder.correctAnswer
            )
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
}

struct QuestionBuilder {
    var text: String = ""
    var type: QuestionType = .multipleChoice
    var options: [String] = ["", "", "", ""]
    var correctAnswer: Int = 0
}

struct QuestionPreviewCard: View {
    let question: QuestionBuilder
    let index: Int
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Q\(index)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(4)
                
                Text(question.type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Text(question.text.isEmpty ? "Untitled Question" : question.text)
                .font(.subheadline)
                .fontWeight(.medium)
            
            if question.type == .multipleChoice {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(question.options.indices, id: \.self) { optionIndex in
                        HStack {
                            Text("\(optionIndex + 1).")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(question.options[optionIndex].isEmpty ? "Option \(optionIndex + 1)" : question.options[optionIndex])
                                .font(.caption)
                                .foregroundColor(optionIndex == question.correctAnswer ? .green : .primary)
                            
                            if optionIndex == question.correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            } else {
                HStack {
                    Text("True/False")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(question.correctAnswer == 0 ? "True" : "False")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
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
    ManualQuizCreationView(quizTitle: .constant("Sample Quiz"))
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self], inMemory: true)
}
