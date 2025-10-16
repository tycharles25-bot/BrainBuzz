//
//  OnboardingGenderView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI

struct OnboardingGenderView: View {
    @State private var selectedGender: GenderOption?
    let onComplete: (GenderOption?) -> Void
    
    enum GenderOption: String, CaseIterable {
        case male = "Male"
        case female = "Female"
        case nonBinary = "Non-binary"
        case preferNotToSay = "Prefer not to say"
    }
    
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
                        Text("What's your gender?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("This information is optional and private")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Gender Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Gender")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(GenderOption.allCases, id: \.self) { option in
                                Button(action: {
                                    selectedGender = option
                                }) {
                                    Text(option.rawValue)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedGender == option ? .white : .black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            selectedGender == option ? Color.black : Color.gray.opacity(0.1)
                                        )
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    onComplete(selectedGender)
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
                    .background(Color.black)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingGenderView { gender in
        print("Gender: \(gender?.rawValue ?? "None")")
    }
}
