//
//  SmartAssistantScreen.swift
//  amdme
//
//  Created by reema on 12/9/25.
//

import SwiftUI

struct SmartAssistantScreen: View {

    // الـ ViewModel الوحيد اللي نشتغل عليه
    @ObservedObject var viewModel: SmartAssistantViewModel

    var body: some View {
        ZStack {
            // MARK: - Background (قدّرياً مشابه للكود حقك)
            LinearGradient(
                colors: [
                    Color(red: 191/255, green: 236/255, blue: 232/255),
                    .white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                // MARK: - Header
                HStack {
                    Text("المساعد الذكي")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0/255, green: 122/255, blue: 130/255))
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0/255, green: 122/255, blue: 130/255))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle().fill(Color.white.opacity(0.6))
                        )
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // MARK: - Description
                Text("خلّ الشخص اللي قدامك يضغط زر التسجيل ويتكلم بجملته، وأنا أرجعها لك بشكل أبسط وأسهل في القراءة.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)
                
                // MARK: - Text Area
                VStack(alignment: .leading, spacing: 8) {
                    
                    // 1) لو فيه خطأ من الـ AI (لو عندك aiError في الفيو مودل)
                    if let error = viewModel.aiError, !error.isEmpty {
                        Text(error)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 2) لو في حالة معالجة (يا أما معالجة الصوت أو تبسيط AI)
                    } else if viewModel.isProcessing || viewModel.isAIProcessing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(.circular)
                            Text("جاري التبسيط…")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(Color(red: 0/255, green: 122/255, blue: 130/255))
                    
                    // 3) لو عندك نص مبسّط من الـ AI
                    } else if !viewModel.simplifiedText.isEmpty {
                        Text(viewModel.simplifiedText)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 4) لو عندك finalText من السبـيتش
                    } else if !viewModel.finalText.isEmpty {
                        Text(viewModel.finalText)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 5) لو في نص لحظي realTimeText
                    } else if !viewModel.realTimeText.isEmpty {
                        Text(viewModel.realTimeText)
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 6) الحالة الفارغة
                    } else {
                        Text("هنا بيظهر النص اللي تم التقاطه أو النص المبسّط بعد المعالجة.")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.9))
                )
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                Spacer()
                
                // MARK: - Recording Button
                VStack(spacing: 8) {
                    Button {
                        // هنا نستخدم الفلو حق الفيو مودل مباشرة
                        if viewModel.isRecording {
                            print("🟥 [UI] Stop recording tapped")
                            viewModel.stopRecording()
                        } else {
                            print("🟢 [UI] Start recording tapped")
                            viewModel.startRecording()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(colors: [
                                        Color(red: 0/255, green: 122/255, blue: 130/255),
                                        Color(red: 0/255, green: 173/255, blue: 181/255)
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 10)
                            
                            Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text(viewModel.isRecording ? "جارٍ التسجيل… تكلم الآن" : "اضغط للتسجيل")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(red: 0/255, green: 122/255, blue: 130/255))
                }
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    // Preview بسيط باستخدام فيومودل وهمي
    SmartAssistantScreen(viewModel: SmartAssistantViewModel())
}
