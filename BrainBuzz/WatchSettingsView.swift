//
//  WatchSettingsView.swift
//  BrainBuzz
//
//  Watch Settings View with Mode Toggle
//

import SwiftUI

struct WatchSettingsView: View {
    @StateObject private var watchManager = WatchBluetoothManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Connection Status Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: watchManager.isConnected ? "applewatch" : "applewatch.slash")
                                .font(.title2)
                                .foregroundColor(watchManager.isConnected ? .green : .gray)
                            
                            Text("Watch Status")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        
                        Text(watchManager.connectionStatus)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if watchManager.isConnected {
                            HStack(spacing: 20) {
                                if watchManager.batteryLevel > 0 {
                                    HStack(spacing: 8) {
                                        Image(systemName: "battery.100")
                                        Text("\(watchManager.batteryLevel)%")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Connection Controls
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "link")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            Text("Connection")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        if !watchManager.isConnected {
                            Button(action: {
                                watchManager.startScanning()
                            }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text("Scan for Watch")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        } else {
                            Button(action: {
                                watchManager.disconnect()
                            }) {
                                HStack {
                                    Image(systemName: "xmark")
                                    Text("Disconnect")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Mode Selection
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "waveform.path")
                                .font(.title2)
                                .foregroundColor(.purple)
                            
                            Text("Feedback Mode")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Text("Choose how the watch responds to wrong answers")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            // Vibration Mode
                            Button(action: {
                                watchManager.setMode(.vibration)
                            }) {
                                HStack {
                                    Image(systemName: watchManager.currentMode == .vibration ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(watchManager.currentMode == .vibration ? .blue : .gray)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Vibration Only")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                        
                                        Text("Low intensity vibration (1.5s)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(watchManager.currentMode == .vibration ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(watchManager.currentMode == .vibration ? Color.blue : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Shock Mode (Optional)
                            Button(action: {
                                watchManager.setMode(.staticShock)
                            }) {
                                HStack {
                                    Image(systemName: watchManager.currentMode == .staticShock ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(watchManager.currentMode == .staticShock ? .orange : .gray)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Shock Mode")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                        
                                        Text("Level 2 shock (200ms)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(watchManager.currentMode == .staticShock ? Color.orange.opacity(0.1) : Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(watchManager.currentMode == .staticShock ? Color.orange : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
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
            .navigationTitle("Watch Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    WatchSettingsView()
}

