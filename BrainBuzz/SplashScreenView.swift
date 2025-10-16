//
//  SplashScreenView.swift
//  BrainBuzz
//
//  Created by Tyler Charles on 10/16/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isLoading = true
    @State private var progress: Double = 0.0
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Lightbulb Icon
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.black)
                    .scaleEffect(isLoading ? 1.0 : 1.1)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isLoading)
                
                Spacer()
                
                // Progress Slider
                VStack(spacing: 12) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .black))
                        .frame(height: 4)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .onAppear {
            startLoading()
        }
    }
    
    private func startLoading() {
        // Animate progress over 3 seconds
        withAnimation(.linear(duration: 3.0)) {
            progress = 1.0
        }
        
        // Complete loading after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                onComplete()
            }
        }
    }
}

#Preview {
    SplashScreenView {
        print("Splash complete")
    }
}
