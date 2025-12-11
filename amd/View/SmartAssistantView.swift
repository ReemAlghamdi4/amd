//
//  SmartAssistantView.swift
//  amdme
//
//  Created by reema aljohani on 12/2/25.
//

import SwiftUI

struct SmartAssistantView: View {
    
    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = SmartAssistantViewModel()
    
    
    // MARK: - Close Button
    var closeButton: some View {
        Button(action: {
            viewModel.stopAll()
            dismiss()
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(red: 0/255, green: 122/255, blue: 130/255))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.60))
                )
        }
    }
    
    
    var body: some View {
        ZStack {
            
            // MARK: Background
            MovingSoftBackground()
                .ignoresSafeArea()
            
            
            VStack(spacing: 0) {
                
                // MARK: - HEADER
                ZStack {
                    Text(LocalizedStringKey("assistant_title"))
                        .font(.custom("IBMPlexSansArabic-Bold", size: 34))
                        .foregroundColor(Color(red: 255/255, green: 145/255, blue: 77/255))
                        .padding(.top, 60)

                    HStack {
                        if layoutDirection == .rightToLeft {
                            Spacer()
                            closeButton
                                .padding(.trailing, 50)
                                .padding(.top, -50)
                        } else {
                            closeButton
                                .padding(.leading, 20)
                                .padding(.top, -50)
                            Spacer()
                        }
                    }
                }
                .padding(.top, 2)
                
                
                // MARK: - TEXT BLOCK
                VStack {
                    Spacer()
                    
                    Group {
                        
                        if viewModel.isProcessing {
                            Text(LocalizedStringKey("processing_text"))
                                .foregroundColor(.black)
                            
                        } else if viewModel.isAIProcessing {
                            Text(LocalizedStringKey("ai_processing_text"))
                                .foregroundColor(.gray)
                            
                        } else if !viewModel.simplifiedText.isEmpty {
                            
                            ScrollView(showsIndicators: false) {
                                Text(viewModel.simplifiedText)
                                    .foregroundColor(.black)
                                    .font(.custom("IBMPlexSansArabic-Bold", size: 26))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 10)
                            }
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.40)
                            
                        } else if !viewModel.finalText.isEmpty {
                            Text(viewModel.finalText)
                                .foregroundColor(.black)
                            
                        } else if viewModel.isRecording {
                            Text(
                                viewModel.realTimeText.isEmpty ?
                                LocalizedStringKey("recording_placeholder") :
                                LocalizedStringKey(viewModel.realTimeText)
                            )
                            .foregroundColor(.gray.opacity(0.55))
                            
                        } else {
                            Text(LocalizedStringKey("show_other_person_text"))
                                .foregroundColor(.black)
                        }
                    }
                    .font(.custom("IBMPlexSansArabic-semibold", size: 25))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .padding(.top, 60)
                    
                    Spacer()
                }

                
                // MARK: - RECORDING BUTTON
                RecordingButton(
                    isRecording: $viewModel.isRecording,
                    isProcessing: $viewModel.isAIProcessing,
                    onTap: {
                        if viewModel.isRecording {
                            print(" [UI] Stop recording tapped")
                            viewModel.stopRecording()
                        } else {
                            print(" [UI] Start recording tapped")
                            viewModel.startRecording()
                        }
                    }
                )
                .frame(width: 255, height: 255)
                .padding(.bottom, -30)
                
            }
            .onDisappear {
                viewModel.stopAll()
            }
        }
        
        
        // MARK: -  HAPTICS
        .onChange(of: viewModel.isRecording) { newValue in
            
            if newValue == true {
                // بداية
                let start = UINotificationFeedbackGenerator()
                start.notificationOccurred(.success)
                
            } else {
                // نهاية
                let stop = UINotificationFeedbackGenerator()
                stop.notificationOccurred(.error)
            }
        }

    }
}

// MARK: - Preview
struct SmartAssistantView_Previews: PreviewProvider {
    static var previews: some View {
        SmartAssistantView()
            .previewDevice("iPhone 16 Pro Max")
    }
}
