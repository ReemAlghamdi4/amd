//
//  SmartAssistantSandboxView.swift
//  amd
//
//  Created by reema on 12/9/25.
//

import SwiftUI

struct SmartAssistantSandboxView: View {

    // نستخدم ViewModel الحقيقي الكامل
    @StateObject private var viewModel = SmartAssistantViewModel()

    // للتحكم اليدوي بالحالات (اختياري)
    @State private var scenario: String = "Real Recording"

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // MARK: - Scenario Picker
                Picker("الحالة", selection: $scenario) {
                    Text("Real Recording").tag("Real Recording")
                    Text("Force Error").tag("Error")
                    Text("Fake AI Result").tag("AI")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Button("تطبيق الحالة اليدوية") {
                    applyScenario()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 10)

                Divider()

                // MARK: - Actual SmartAssistantScreen Preview (Recording Works Here)
                SmartAssistantScreen(viewModel: viewModel)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Smart Assistant Sandbox")
        }
    }

    // MARK: - Scenario Handler
    private func applyScenario() {

        switch scenario {

        case "Real Recording":
            // نرجع كل شيء للوضع الطبيعي
            viewModel.isRecording = false
            viewModel.isProcessing = false
            viewModel.isAIProcessing = false
            viewModel.realTimeText = ""
            viewModel.finalText = ""
            viewModel.simplifiedText = ""
            viewModel.aiError = nil

            print("🎤 Ready for REAL recording")

        case "Error":
            viewModel.aiError = "⚠️ هذا خطأ تجريبي"
            viewModel.realTimeText = ""
            viewModel.finalText = ""
            viewModel.simplifiedText = ""
            print("⚠️ Fake error triggered")

        case "AI":
            viewModel.finalText = "هذا نص تجريبي للتبسيط"
            viewModel.realTimeText = ""
            viewModel.isProcessing = false

            // استدعاء التبسيط الحقيقي
            viewModel.simplifyText()
            print("🤖 Sent fake text to real AI")

        default:
            break
        }
    }
}

#Preview {
    SmartAssistantSandboxView()
}
