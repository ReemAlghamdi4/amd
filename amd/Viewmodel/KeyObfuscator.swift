//
//  KeyObfuscator.swift.swift
//  amd
//
//  Created by reema aljohani on 12/8/25.
//

import Foundation

struct KeyObfuscator {
    
    // XOR helper
    static func xor(_ data: Data, with key: UInt8) -> Data {
        return Data(data.map { $0 ^ key })
    }
    
    // Split + XOR
    static func obfuscate(_ string: String) -> [String] {
        let bytes = Array(string.utf8)
        
        let part1 = Data(bytes.prefix(bytes.count / 3))
        let part2 = Data(bytes.dropFirst(bytes.count / 3).prefix(bytes.count / 3))
        let part3 = Data(bytes.dropFirst(2 * (bytes.count / 3)))
        
        let k1: UInt8 = 17
        let k2: UInt8 = 93
        let k3: UInt8 = 201
        
        let e1 = xor(part1, with: k1).base64EncodedString()
        let e2 = xor(part2, with: k2).base64EncodedString()
        let e3 = xor(part3, with: k3).base64EncodedString()
        
        return [e1, e2, e3]
    }
    
    // Rebuild original key
    static func reunite(_ parts: [String]) -> String {
        let k1: UInt8 = 17
        let k2: UInt8 = 93
        let k3: UInt8 = 201
        
        guard
            let p1 = Data(base64Encoded: parts[0]),
            let p2 = Data(base64Encoded: parts[1]),
            let p3 = Data(base64Encoded: parts[2])
        else { return "" }
        
        let d1 = xor(p1, with: k1)
        let d2 = xor(p2, with: k2)
        let d3 = xor(p3, with: k3)
        
        let full = d1 + d2 + d3
        return String(data: full, encoding: .utf8) ?? ""
    }
}
