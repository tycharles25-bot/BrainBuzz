//
//  Item.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import Foundation
import SwiftData

// MARK: - Quiz Models

@Model
final class Quiz {
    var id: UUID
    var title: String
    var questions: [Question]
    var createdAt: Date
    var isDemo: Bool
    
    init(title: String, questions: [Question] = [], isDemo: Bool = false) {
        self.id = UUID()
        self.title = title
        self.questions = questions
        self.createdAt = Date()
        self.isDemo = isDemo
    }
}

@Model
final class Question {
    var id: UUID
    var text: String
    var type: QuestionType
    var options: [String]
    var correctAnswer: Int
    var quiz: Quiz?
    
    init(text: String, type: QuestionType, options: [String], correctAnswer: Int) {
        self.id = UUID()
        self.text = text
        self.type = type
        self.options = options
        self.correctAnswer = correctAnswer
    }
}

enum QuestionType: String, CaseIterable, Codable {
    case trueFalse = "trueFalse"
    case multipleChoice = "multipleChoice"
    
    var displayName: String {
        switch self {
        case .trueFalse:
            return "True/False"
        case .multipleChoice:
            return "Multiple Choice"
        }
    }
}

@Model
final class QuizResult {
    var id: UUID
    var quiz: Quiz?
    var score: Int
    var totalQuestions: Int
    var completedAt: Date
    var answers: [Int]
    
    init(quiz: Quiz?, score: Int, totalQuestions: Int, answers: [Int]) {
        self.id = UUID()
        self.quiz = quiz
        self.score = score
        self.totalQuestions = totalQuestions
        self.completedAt = Date()
        self.answers = answers
    }
    
    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }
}

// MARK: - Motivation Model

@Model
final class MotivationQuote {
    var id: UUID
    var text: String
    var author: String
    var createdAt: Date
    
    init(text: String, author: String) {
        self.id = UUID()
        self.text = text
        self.author = author
        self.createdAt = Date()
    }
}

// MARK: - Legacy Item (keeping for compatibility)
@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
