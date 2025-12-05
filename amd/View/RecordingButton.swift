//
//  RecordingButton.swift
//  amdme
//
//  Created by reema aljohani on 12/2/25.
//
import SwiftUI

struct RecordingButton: View {
    
    @Binding var isRecording: Bool
    @Binding var isProcessing: Bool
    
    @State private var scale1: CGFloat = 1.0
    @State private var scale2: CGFloat = 1.0
    @State private var scale3: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            
            // MARK: - Blobs 
            Image("1")
                .resizable()
                .scaledToFit()
                .opacity(0.55)
                .scaleEffect(1.0 * scale1)

            Image("2")
                .resizable()
                .scaledToFit()
                .opacity(0.40)
                .scaleEffect(0.96 * scale2)

            Image("3")
                .resizable()
                .scaledToFit()
                .opacity(0.34)
                .scaleEffect(0.92 * scale3)
            
            // MARK: - Mic / Spinner
            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else {
                Image(systemName: "mic.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isProcessing else { return }
            isRecording.toggle()
            
            if isRecording {
                startAnimations()
            } else {
                resetAnimations()
            }
        }
    }
    
    
    // MARK: - Animations
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.3).repeatForever()) {
            scale1 = 1.06
        }
        withAnimation(.easeInOut(duration: 2.8).repeatForever().delay(0.2)) {
            scale2 = 1.10
        }
        withAnimation(.easeInOut(duration: 3.2).repeatForever().delay(0.35)) {
            scale3 = 1.14
        }
    }
    
    private func resetAnimations() {
        withAnimation(.easeInOut(duration: 0.25)) {
            scale1 = 1.0
            scale2 = 1.0
            scale3 = 1.0
        }
    }
}

struct RecordingButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white
            RecordingButton(
                isRecording: .constant(false),
                isProcessing: .constant(false)
            )
            .frame(width: 220, height: 220)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

