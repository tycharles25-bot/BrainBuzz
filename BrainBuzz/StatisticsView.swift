//
//  StatisticsView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \QuizResult.completedAt) private var quizResults: [QuizResult]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if quizResults.isEmpty {
                        // Empty State
                        VStack(spacing: 24) {
                            Spacer()
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 80))
                                .foregroundColor(.secondary)
                            
                            Text("No Quiz Data Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text("Take some quizzes to see your progress here!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        // Statistics Content
                        VStack(spacing: 24) {
                            // Overall Stats
                            VStack(spacing: 16) {
                                Text("Overall Performance")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Average Score",
                                value: String(format: "%.0f%%", averageScore),
                                icon: "chart.bar",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Best Score",
                                value: String(format: "%.0f%%", bestScore),
                                icon: "star.fill",
                                color: .orange
                            )
                        }
                            }
                            .padding(.horizontal)
                            
                            // Progress Chart
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Progress Over Time")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                if #available(iOS 16.0, *) {
                                    Chart(quizResults.indices, id: \.self) { index in
                                        LineMark(
                                            x: .value("Quiz", index + 1),
                                            y: .value("Score", quizResults[index].percentage)
                                        )
                                        .foregroundStyle(.blue)
                                        .interpolationMethod(.catmullRom)
                                        
                                        AreaMark(
                                            x: .value("Quiz", index + 1),
                                            y: .value("Score", quizResults[index].percentage)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .interpolationMethod(.catmullRom)
                                    }
                                    .frame(height: 200)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    .padding(.horizontal)
                                } else {
                                    // Fallback for older iOS versions
                                    VStack {
                                        Text("Chart requires iOS 16+")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        // Simple text-based chart
                                        VStack(spacing: 8) {
                                            ForEach(quizResults.indices, id: \.self) { index in
                                                HStack {
                                                    Text("Quiz \(index + 1)")
                                                        .font(.caption)
                                                        .frame(width: 60, alignment: .leading)
                                                    
                                                    HStack {
                                                        Rectangle()
                                                            .fill(Color.blue)
                                                            .frame(width: CGFloat(quizResults[index].percentage) * 2, height: 8)
                                                            .cornerRadius(4)
                                                        
                                                        Spacer()
                                                        
                                                        Text(String(format: "%.0f%%", quizResults[index].percentage))
                                                            .font(.caption)
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                            }
                                        }
                                        .padding()
                                    }
                                    .frame(height: 200)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Recent Results
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Results")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 8) {
                                    ForEach(quizResults.suffix(5).reversed(), id: \.id) { result in
                                        RecentResultCard(result: result)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            Spacer(minLength: 50)
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
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
    
    private var averageScore: Double {
        guard !quizResults.isEmpty else { return 0 }
        return quizResults.reduce(0.0) { $0 + $1.percentage } / Double(quizResults.count)
    }
    
    private var bestScore: Double {
        quizResults.map { $0.percentage }.max() ?? 0
    }
    
    private var currentStreak: Int {
        var streak = 0
        let sortedResults = quizResults.sorted { $0.completedAt > $1.completedAt }
        
        for result in sortedResults {
            if result.percentage >= 70 { // Consider 70%+ as passing
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct RecentResultCard: View {
    let result: QuizResult
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.quiz?.title ?? "Unknown Quiz")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(result.completedAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.0f%%", result.percentage))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor)
                
                Text("\(result.score)/\(result.totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var scoreColor: Color {
        switch result.percentage {
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
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Quiz.self, Question.self, QuizResult.self, MotivationQuote.self, Item.self], inMemory: true)
}
