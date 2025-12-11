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
    var onTap: () -> Void

    @State private var scale1: CGFloat = 1.0
    @State private var scale2: CGFloat = 1.0
    @State private var scale3: CGFloat = 1.0

    var body: some View {
        ZStack {

            // MARK: - Blobs (Always Visible)
            Image("1")
                .resizable()
                .scaledToFit()
                .opacity(0.50)
                .scaleEffect(scale1)

            Image("2")
                .resizable()
                .scaledToFit()
                .opacity(0.35)
                .scaleEffect(scale2)

            Image("3")
                .resizable()
                .scaledToFit()
                .opacity(0.30)
                .scaleEffect(scale3)


            // MARK: - Mic or Spinner
            Group {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2.0)
                } else {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isProcessing)

        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isProcessing else { return }
            onTap()
        }
        .onChange(of: isRecording) { newValue in
            if newValue { startAnimations() }
            else { resetAnimations() }
        }
        .onChange(of: isProcessing) { newValue in
            if newValue {
                resetAnimations()
            } else if isRecording {
                startAnimations()
            }
        }
    }

    // MARK: - Animations
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.3).repeatForever()) { scale1 = 1.08 }
        withAnimation(.easeInOut(duration: 2.8).repeatForever().delay(0.2)) { scale2 = 1.12 }
        withAnimation(.easeInOut(duration: 3.2).repeatForever().delay(0.35)) { scale3 = 1.16 }
    }

    private func resetAnimations() {
        withAnimation(.easeInOut(duration: 0.2)) {
            scale1 = 1.0
            scale2 = 1.0
            scale3 = 1.0
        }
    }
}
