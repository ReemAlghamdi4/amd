//  SmartAssistantViewModel.swift
//  amd
//
//  Created by reema aljohani on 12/3/25.
//

import Foundation
import AVFoundation
import Speech
import Combine

class SmartAssistantViewModel: NSObject, ObservableObject {
    
    // MARK: - Published States (UI Binding)
    @Published var isRecording: Bool = false
    @Published var isProcessing: Bool = false
    @Published var isAIProcessing: Bool = false
    
    @Published var realTimeText: String = ""
    @Published var finalText: String = ""
    @Published var simplifiedText: String = ""
    @Published var aiError: String? = nil
    
    
    // MARK: - Speech Engine
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    

    // MARK: - Init
    override init() {
        super.init()
        requestSpeechPermission()
    }
    
    
    // MARK: - Permissions
    func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech permission not granted")
            }
        }
    }
    
    
    // MARK: - Start Recording
    func startRecording() {
        
        guard !isAIProcessing else {
            print("AI still processing — cannot start new recording.")
            return
        }
        
        cleanup()
        
        isRecording = true
        isProcessing = false
        
        realTimeText = ""
        finalText = ""
        simplifiedText = ""
        
        request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        setupAudioSession()
        startAudioEngine()
        startRecognitionTask()
        
        print("🎙️ Recording started.")
    }
    
    
    // MARK: - Stop Recording
    func stopRecording() {
        
        guard isRecording else { return }
        
        print("Stopping recording…")
        
        isRecording = false
        isProcessing = true
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.finish()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            
            self.isProcessing = false
            
            guard !self.finalText.trimmingCharacters(in: .whitespaces).isEmpty else {
                print("No speech detected.")
                return
            }
            
            self.simplifyText()
        }
    }
    
    
    // MARK: - Audio Session
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true)
        } catch {
            print("Audio session error:", error.localizedDescription)
        }
    }
    
    
    // MARK: - Start Audio Engine
    private func startAudioEngine() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.request.append(buffer)
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed:", error.localizedDescription)
        }
    }
    
    
    // MARK: - Recognition Task
    private func startRecognitionTask() {
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            
            if let result = result {
                DispatchQueue.main.async {
                    self.realTimeText = result.bestTranscription.formattedString
                    
                    if result.isFinal {
                        self.finalText = self.realTimeText
                        self.realTimeText = ""
                        self.isProcessing = false
                        
                        // Debug
                        print("Final recognized text:", self.finalText)
                    }
                }
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    print("Recognition error:", error!.localizedDescription)
                    self.isRecording = false
                    self.isProcessing = false
                }
            }
        }
    }
    
    // MARK: - Cleanup
    private func cleanup() {
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.reset()
    }
    
    
    // MARK: - AI: Simplify Text
    func simplifyText() {
        
        guard !isAIProcessing else { return }
        guard !finalText.isEmpty else { return }
        
        isAIProcessing = true
        simplifiedText = ""
        aiError = nil
        
        print("Sending text to OpenAI API…")
        
        // Debug API key (safe version)
        print("API Key exists:", !APIKeyManager.shared.openAIKey.isEmpty)
        print("First 6 chars:", APIKeyManager.shared.openAIKey.prefix(6))

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(APIKeyManager.shared.openAIKey)"
        ]
        
        
        let prompt = """
        أريدك أن تعيد كتابة النص التالي بلغة عربية مبسّطة جدًا:
        - كلمات قصيرة وواضحة.
        - جمل قصيرة.
        - بدون تفاصيل غير ضرورية.
        - مناسبة لشخص قدراته اللغوية بسيطة.

        النص الأصلي:
        \(finalText)
        """

        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
        
        print("Request ready. Sending now…")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.aiError = "خطأ في الاتصال بالخادم."
                    self.isAIProcessing = false
                }
                print("AI Error:", error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            // Debug full raw response
            print("AI RAW RESPONSE:")
            print(String(data: data, encoding: .utf8) ?? "nil")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let msg = choices.first?["message"] as? [String: Any],
                   let content = msg["content"] as? String {
                    
                    DispatchQueue.main.async {
                        self.simplifiedText = content
                        self.isAIProcessing = false
                    }
                    
                    print("AI simplified text:", content)
                    
                } else {
                    throw NSError(domain: "", code: -1, userInfo: nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.aiError = "تعذر قراءة استجابة الذكاء الاصطناعي."
                    self.isAIProcessing = false
                }
                print("JSON Parse Error:", error.localizedDescription)
            }
            
        }.resume()
    }
}
