//
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

    // MARK: - Published UI States
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

    private var preparedSession = false


    // MARK: - Init
    override init() {
        super.init()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.requestSpeechPermission()
        }
    }

    deinit {
        stopAll()
    }


    // MARK: - Permission
    private func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech permission not granted")
            }
        }
    }


    // MARK: - START RECORDING
    func startRecording() {

        guard !isRecording else { return }
        guard !isAIProcessing else { return }

        print("StartRecording requested")
        isRecording = true
        isProcessing = false

        stopAll {      // Safe reset, then start
            self.beginRecording()
        }
    }


    // MARK: - BEGIN RECORDING
    private func beginRecording() {

        print("beginRecording()")

        realTimeText = ""
        finalText = ""
        simplifiedText = ""

        request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        setupAudioSession()
        startAudioEngine()
        startRecognitionTask()

        print("Recording ACTIVE")
    }


    // MARK: - STOP RECORDING
    func stopRecording() {

        guard isRecording else { return }

        print("stopRecording()")
        isRecording = false
        isProcessing = true

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request.endAudio()      // <-- مهم جدًا


        // النص النهائي سيأتي داخل result.isFinal في startRecognitionTask
    }


    // MARK: - Audio Session
    private func setupAudioSession() {

        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(
                .playAndRecord,
                mode: .measurement,
                options: [.duckOthers, .allowBluetooth]
            )
            try session.setActive(true)

            print("AudioSession READY")

        } catch {
            print("AudioSession Error:", error.localizedDescription)
        }
    }


    // MARK: - Audio Engine
    private func startAudioEngine() {

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)

        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { buffer, _ in
            self.request.append(buffer)
        }

        do {
            try audioEngine.start()
            print("AudioEngine STARTED")
        } catch {
            print("Audio engine failed:", error.localizedDescription)
        }
    }


    // MARK: - Speech Recognition Task
    private func startRecognitionTask() {

        recognitionTask = speechRecognizer?.recognitionTask(with: request) {
            result, error in

            if let result = result {

                DispatchQueue.main.async {
                    self.realTimeText = result.bestTranscription.formattedString
                }

                // FINAL RESULT — WE PROCESS HERE
                if result.isFinal {
                    DispatchQueue.main.async {
                        self.finalText = result.bestTranscription.formattedString
                        self.realTimeText = ""
                        self.isProcessing = false

                        print("Final recognized:", self.finalText)

                        if !self.finalText.trimmingCharacters(in: .whitespaces).isEmpty {
                            self.simplifyText()
                        }
                    }
                }
            }

            // Error
            if let error = error {
                print("Recognition error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.isRecording = false
                    self.isProcessing = false
                }
            }
        }
    }


    // MARK: - STOP ALL (Safe Reset)
    func stopAll(completion: (() -> Void)? = nil) {

        print("stopAll() – full stop")

        recognitionTask?.cancel()
        recognitionTask = nil

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.reset()

        isProcessing = false
        isAIProcessing = false
        preparedSession = false

        // Give engine a micro moment to settle
        DispatchQueue.main.async {
            completion?()
        }
    }


    // MARK: - AI Simplification
    func simplifyText() {

        guard !isAIProcessing else { return }
        guard !finalText.isEmpty else { return }

        isAIProcessing = true
        simplifiedText = ""

        print("Sending text to OpenAI…")
        print("API Key Exists:", !APIKeyManager.shared.openAIKey.isEmpty)

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

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.allHTTPHeaderFields = headers
        req.httpBody = jsonData

        URLSession.shared.dataTask(with: req) { data, response, error in

            if let error = error {
                print("AI Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.isAIProcessing = false
                }
                return
            }

            guard let data = data else { return }

            print("RAW AI Response:")
            print(String(data: data, encoding: .utf8) ?? "nil")

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let msg = (json?["choices"] as? [[String: Any]])?.first?["message"] as? [String: Any]
                let content = msg?["content"] as? String ?? "?"

                DispatchQueue.main.async {
                    self.simplifiedText = content
                    self.isAIProcessing = false
                }

            } catch {
                print("JSON Parse Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.isAIProcessing = false
                }
            }

        }.resume()
    }
}
