//
//  SmartAssistantMainView.swift
//  amd
//
//  Created by reema aljohani on 12/10/25.
//

import SwiftUI

struct SmartAssistantMainView: View {
    
    // هنا نمسك نسخة وحدة من الفيو مودل طول ما الصفحة مفتوحة
    @StateObject private var viewModel = SmartAssistantViewModel()
    
    var body: some View {
        SmartAssistantScreen(viewModel: viewModel)
    }
}

#Preview {
    SmartAssistantMainView()
}
