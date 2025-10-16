//
//  OnboardingAgeView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI

struct OnboardingAgeView: View {
    @State private var age = ""
    let onComplete: (Int) -> Void
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Indicator
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 60)
                    
                    // Progress Bar
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                    .frame(height: 80)
                
                // Main Content
                VStack(spacing: 32) {
                    // Title
                    VStack(spacing: 12) {
                        Text("How old are you?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("This helps us customize content for you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Input Field
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Age")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .frame(width: 20)
                            
                            TextField("Enter your age", text: $age)
                                .font(.body)
                                .textFieldStyle(PlainTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Complete Setup Button
                Button(action: {
                    if let ageInt = Int(age) {
                        onComplete(ageInt)
                    }
                }) {
                    HStack {
                        Text("Complete Setup")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValidAge ? Color.black : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!isValidAge)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var isValidAge: Bool {
        guard let ageInt = Int(age) else { return false }
        return ageInt >= 1 && ageInt <= 120
    }
}

#Preview {
    OnboardingAgeView { age in
        print("Age: \(age)")
    }
}
