//
//  amdApp.swift
//  amd
//
//  Created by Reem alghamdi on 07/06/1447 AH.
//

import SwiftUI

@main
struct amdApp: App {
    
    
   /* @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomePage()
                    .navigationBarBackButtonHidden(true)
            } else {
                ContentView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}*/
    
    /* var body: some Scene {
     WindowGroup {
     // لو تبين تروحين مباشرة لصفحة المساعد الذكي:
     SmartAssistantMainView()
     
     // ولو في المستقبل تبين ترجعين للأونبوردنق:
     // ContentView()
     }
     }
     }
     */
    
    var body: some Scene {
        WindowGroup {
    SmartAssistantView()
        }
    }
}

