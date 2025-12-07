//
//  bg.swift
//  amd
//
//  Created by Reem alghamdi on 13/06/1447 AH.
//

import SwiftUI

// MARK: - خلفية متحركة ناعمة
struct bg: View {
    @State private var move1 = false
    @State private var move2 = false
    @State private var move3 = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // الدائرة المينت الفاتحة — زودي قوة اللون هنا لو تبين
            Circle()
                .fill(Color("blue4").opacity(0.1))
                .frame(width: 480, height: 480)
                .blur(radius: 95)
                .offset(x: move1 ? 140 : -140,
                        y: move1 ? -200 : 160)
                .animation(.easeInOut(duration: 18).repeatForever(autoreverses: true), value: move1)
            
            // دائرة مينت أوضح (لون أقوى)
            Circle()
                .fill(Color("blue4").opacity(0.3))
                .frame(width: 420, height: 420)
                .blur(radius: 120)
                .offset(x: move2 ? -180 : 150,
                        y: move2 ? 240 : -180)
                .animation(.easeInOut(duration: 22).repeatForever(autoreverses: true), value: move2)
            Circle()
                .fill(Color(red: 1.00, green: 0.75, blue: 0.57))
                .frame(width: 360, height: 360)
                .blur(radius: 120)
                .offset(x: move3 ? 140 : -140,
                        y: move3 ? 180 : -140)
                .animation(.easeInOut(duration: 26).repeatForever(autoreverses: true), value: move3)
            // الدائرة الدافئة (لون خوخي)
           
        }
        .onAppear {
            move1 = true
            move2 = true
            move3 = true
        }
    }
}



#Preview {
    bg()
}
