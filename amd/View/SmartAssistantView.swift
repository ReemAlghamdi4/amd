//
//  SmartAssistantView.swift
//  amdme
//
//  Created by reema aljohani on 12/2/25.

import SwiftUI

struct SmartAssistantView: View {
    
    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.dismiss) private var dismiss

    @State private var isRecording = false
    @State private var isProcessing = false
    @State private var realTimeText = ""
    @State private var finalText = ""
    
    ///huhu
    
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
            
            /*// MARK: - Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 191/255, green: 236/255, blue: 232/255),
                    .white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()*/
            
            
            VStack(spacing: 0) {
                
                // MARK: - HEADER
                ZStack {
                    
                    Text(NSLocalizedString("assistant_title", comment: ""))
                        .font(.custom("IBMPlexSansArabic-Bold", size: 34))
                        .foregroundColor(Color(red: 255/255, green: 145/255, blue: 77/255))
                        .padding(.top, 60)
                    
                    
                    // X Button —  RTL/LTR
                    HStack {
                        if layoutDirection == .rightToLeft {
                            Spacer()
                            closeButton
                                .padding(.trailing, 20)
                                .padding(.top, -50)
                        } else {
                            closeButton
                                .padding(.leading, 20)
                                .padding(.top, -50)
                            Spacer()
                        }
                    }
                }
                .padding(.top, 1)
                
                
                
                // MARK: - TEXT BLOCK (CENTERED)
                VStack {
                    
                    Spacer()
                    
                    Group {
                        if isProcessing {
                            Text(NSLocalizedString("processing_text", comment: ""))
                                .foregroundColor(.black)
                            
                        } else if !finalText.isEmpty {
                            Text(finalText)
                                .foregroundColor(.black)
                            
                        } else if isRecording {
                            Text(realTimeText.isEmpty ?
                                 NSLocalizedString("recording_placeholder", comment: "") :
                                 realTimeText
                            )
                            .foregroundColor(.gray.opacity(0.55))
                            
                        } else {
                            Text(NSLocalizedString("show_other_person_text", comment: ""))
                                .foregroundColor(.black)
                        }
                    }
                    .font(.custom("IBMPlexSansArabic-semibold", size: 25))                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                
                
                // MARK: - RECORDING BUTTON (BOTTOM)
                RecordingButton(isRecording: $isRecording, isProcessing: $isProcessing)
                    .frame(width: 255, height: 255)
                    .padding(.bottom, -30)
            }
        }
        .background(
            MovingSoftBackground()
        )
    }
}



// MARK: - Preview
struct SmartAssistantView_Previews: PreviewProvider {
    static var previews: some View {
        SmartAssistantView()
            .previewDevice("iPhone 16 Pro Max")
    }
}
