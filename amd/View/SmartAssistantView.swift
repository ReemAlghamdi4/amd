//
//  SmartAssistantView.swift
//  amdme
//
//  Created by reema aljohani on 12/2/25.


import SwiftUI

struct SmartAssistantView: View {
    
    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = SmartAssistantViewModel()
    
    
    // MARK: - Close Button
    var closeButton: some View {
        Button(action: {
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
                    Text(NSLocalizedString("assistant_title", comment: ""))
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
                            Text(NSLocalizedString("processing_text", comment: ""))
                                .foregroundColor(.black)

                        } else if viewModel.isAIProcessing {
                            Text("جاري تبسيط النص…")
                                .foregroundColor(.gray)

                        } else if !viewModel.simplifiedText.isEmpty {
                            VStack(spacing: 12) {
                                // النص الأصلي
                                Text(viewModel.finalText)
                                    .foregroundColor(.black)

                                // النص المبسّط
                                Text(viewModel.simplifiedText)
                                    .foregroundColor(Color(red: 0/255, green: 122/255, blue: 130/255))
                                    .font(.custom("IBMPlexSansArabic-Regular", size: 23))
                                    .padding(.top, 10)
                            }

                        } else if !viewModel.finalText.isEmpty {
                            Text(viewModel.finalText)
                                .foregroundColor(.black)

                        } else if viewModel.isRecording {
                            Text(
                                viewModel.realTimeText.isEmpty ?
                                NSLocalizedString("recording_placeholder", comment: "") :
                                viewModel.realTimeText
                            )
                            .foregroundColor(.gray.opacity(0.55))

                        } else {
                            Text(NSLocalizedString("show_other_person_text", comment: ""))
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
                    isProcessing: $viewModel.isProcessing
                )
                .frame(width: 255, height: 255)
                .padding(.bottom, -30)
            }
        }
        .onChange(of: viewModel.isRecording) { newValue in
            if newValue {
                viewModel.startRecording()
            } else {
                viewModel.stopRecording()
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
