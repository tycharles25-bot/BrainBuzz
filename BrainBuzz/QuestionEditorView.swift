//
//  QuestionEditorView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI

struct QuestionEditorView: View {
    @State private var question: QuestionBuilder
    let onSave: (QuestionBuilder) -> Void
    let onCancel: () -> Void
    
    init(question: QuestionBuilder, onSave: @escaping (QuestionBuilder) -> Void, onCancel: @escaping () -> Void) {
        self._question = State(initialValue: question)
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Question Type Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Question Type")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Question Type", selection: $question.type) {
                            ForEach(QuestionType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Question Text
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Question")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("Enter your question", text: $question.text, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    // Answer Options
                    if question.type == .multipleChoice {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Answer Options")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 12) {
                                ForEach(question.options.indices, id: \.self) { index in
                                    HStack {
                                        Button(action: {
                                            question.correctAnswer = index
                                        }) {
                                            Image(systemName: question.correctAnswer == index ? "checkmark.circle.fill" : "circle")
                                                .font(.title2)
                                                .foregroundColor(question.correctAnswer == index ? .green : .gray)
                                        }
                                        
                                        TextField("Option \(index + 1)", text: $question.options[index])
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                }
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Correct Answer")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 8) {
                                Button(action: {
                                    question.correctAnswer = 0
                                }) {
                                    HStack {
                                        Image(systemName: question.correctAnswer == 0 ? "checkmark.circle.fill" : "circle")
                                            .font(.title2)
                                            .foregroundColor(question.correctAnswer == 0 ? .green : .gray)
                                        
                                        Text("True")
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    question.correctAnswer = 1
                                }) {
                                    HStack {
                                        Image(systemName: question.correctAnswer == 1 ? "checkmark.circle.fill" : "circle")
                                            .font(.title2)
                                            .foregroundColor(question.correctAnswer == 1 ? .green : .gray)
                                        
                                        Text("False")
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(question)
                    }
                    .disabled(question.text.isEmpty || (question.type == .multipleChoice && question.options.contains { $0.isEmpty }))
                }
            }
        }
    }
}

#Preview {
    QuestionEditorView(
        question: QuestionBuilder(),
        onSave: { _ in },
        onCancel: { }
    )
}
