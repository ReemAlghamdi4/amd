//
//  APIKeyManager.swift
//  amd
//
//  Created by reema aljohani on 12/8/25.
//

import Foundation

class APIKeyManager {
    
    static let shared = APIKeyManager()
    
    private var obfuscatedParts: [String] = []
    
    private init() {
        loadAndObfuscateKey()
    }
    
    private func loadAndObfuscateKey() {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "json") else {
            print("Config.json not found in bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let apiKey = json?["apiKey"] as? String else {
                print("apiKey not found in Config.json")
                return
            }
            
            obfuscatedParts = KeyObfuscator.obfuscate(apiKey)
            
        } catch {
            print("Failed loading Config.json:", error.localizedDescription)
        }
    }
    
    var openAIKey: String {
        KeyObfuscator.reunite(obfuscatedParts)
    }
}
