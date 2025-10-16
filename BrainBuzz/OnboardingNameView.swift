//
//  OnboardingNameView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI

struct OnboardingNameView: View {
    @State private var firstName = ""
    let onComplete: (String) -> Void
    
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
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.3))
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
                        Text("What's your name?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("Let's personalize your BrainBuzz experience")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Input Field
                    VStack(alignment: .leading, spacing: 12) {
                        Text("First Name")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        HStack {
                            Image(systemName: "person")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .frame(width: 20)
                            
                            TextField("Enter your first name", text: $firstName)
                                .font(.body)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    onComplete(firstName)
                }) {
                    HStack {
                        Text("Continue")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(firstName.isEmpty ? Color.gray : Color.black)
                    .cornerRadius(12)
                }
                .disabled(firstName.isEmpty)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingNameView { name in
        print("Name: \(name)")
    }
}
