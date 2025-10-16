//
//  MotivationView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData

struct MotivationView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var quotes: [MotivationQuote]
    @State private var currentQuoteIndex = 0
    @State private var showingNewQuote = false
    
    var currentQuote: MotivationQuote? {
        guard !quotes.isEmpty else { return nil }
        return quotes[currentQuoteIndex]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let quote = currentQuote {
                    // Main Quote Display
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Quote Icon
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.black)
                        
                        // Quote Text
                        Text(quote.text)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .lineSpacing(8)
                        
                        // Quote Author
                        Text("— \(quote.author)")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.horizontal, 32)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    
                    // Clean bottom spacing
                    Spacer(minLength: 50)
                } else {
                    // Empty State
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "lightbulb")
                            .font(.system(size: 80))
                            .foregroundColor(.secondary)
                        
                        Text("No Motivation Quotes")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Add some inspirational quotes to get motivated!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add Quote") {
                            showingNewQuote = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Motivation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewQuote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewQuote) {
            AddQuoteView()
        }
        .onAppear {
            // Generate a new random quote each time the view appears
            if !quotes.isEmpty {
                currentQuoteIndex = Int.random(in: 0..<quotes.count)
            }
        }
    }
    
}

struct AddQuoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var quoteText = ""
    @State private var author = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quote")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $quoteText)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Author")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("Enter author name", text: $author)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveQuote()
                    }
                    .disabled(quoteText.isEmpty || author.isEmpty)
                }
            }
        }
    }
    
    private func saveQuote() {
        let newQuote = MotivationQuote(text: quoteText, author: author)
        modelContext.insert(newQuote)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving quote: \(error)")
        }
    }
}

#Preview {
    MotivationView()
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self], inMemory: true)
}
