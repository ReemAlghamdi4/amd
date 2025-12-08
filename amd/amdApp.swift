//
//  amdApp.swift
//  amd
//
//  Created by Reem alghamdi on 07/06/1447 AH.
//

import SwiftUI

@main
struct amdApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomePage() // or HomeView() if you want to skip HomePage too
                    .navigationBarBackButtonHidden(true)
            } else {
                ContentView() // Onboarding screen in onbording.swift
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}
