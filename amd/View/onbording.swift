//
//  onbording.swift
//  amd
//
//  Created by maha althwab on 12/06/1447 AH.
//

import SwiftUI

// MARK: - توسيع String لإضافة تنسيق مخصص لكلمة "أمد"
extension String {
    var highlightedAMAD: AttributedString {
        var att = AttributedString(self)
        att.foregroundColor = Color(red: 1.0, green: 0.57, blue: 0.30)
        att.font = .system(size: 20, weight: .bold)
        return att
    }
}



// MARK: - خلفية متحركة (Soft Moving Background)
struct MovingSoftBackground: View {
    @State private var move1 = false
    @State private var move2 = false
    @State private var move3 = false
    
    var body: some View {
        ZStack {
            Color.white
            
            Circle()
                .fill(Color(red: 0.80, green: 0.94, blue: 0.92))
                .frame(width: 450, height: 450)
                .blur(radius: 90)
                .offset(x: move1 ? 120 : -120,
                        y: move1 ? -180 : 150)
                .animation(.easeInOut(duration: 18).repeatForever(autoreverses: true), value: move1)
            
            Circle()
                .fill(Color(red: 0.65, green: 0.88, blue: 0.86))
                .frame(width: 380, height: 380)
                .blur(radius: 110)
                .offset(x: move2 ? -150 : 160,
                        y: move2 ? 200 : -160)
                .animation(.easeInOut(duration: 22).repeatForever(autoreverses: true), value: move2)
            
            Circle()
                .fill(Color(red: 1.00, green: 0.75, blue: 0.57))
                .frame(width: 360, height: 360)
                .blur(radius: 120)
                .offset(x: move3 ? 140 : -140,
                        y: move3 ? 180 : -140)
                .animation(.easeInOut(duration: 26).repeatForever(autoreverses: true), value: move3)
        }
        .ignoresSafeArea()
        .onAppear {
            move1 = true
            move2 = true
            move3 = true
        }
    }
}



// MARK: - شريحة Onboarding
struct OnboardSlide: View {
    let title: String
    let subtitle: AttributedString
    let iconName: String
    
    @State private var showIcon = false
    @State private var showText = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // ----- الأيقونة -----
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
                    .opacity(0.90)
                    .blur(radius: 0.8)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
                
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
                    .foregroundColor(Color(red: 0.40, green: 0.65, blue: 0.64))
            }
            .scaleEffect(showIcon ? 1 : 0.6)
            .opacity(showIcon ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.10), value: showIcon)
            
            Spacer().frame(height: 36)
            
            // ----- النصوص -----
            VStack(spacing: 14) {
                Text(title)
                    .font(.system(size: 29, weight: .bold))
                    .foregroundColor(.black.opacity(0.88))
                
                Text(subtitle)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .font(.system(size: 17))
            }
            .offset(y: showText ? 0 : 24)
            .opacity(showText ? 1 : 0)
            .animation(.easeOut(duration: 0.55).delay(0.20), value: showText)
            
            Spacer(minLength: 80)
        }
        .onAppear {
            showIcon = true
            showText = true
        }
        .onDisappear {
            showIcon = false
            showText = false
        }
    }
}



// MARK: - Page Indicator
struct PageIndicator: View {
    let count: Int
    let currentIndex: Int
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex
                          ? Color(red: 0.40, green: 0.65, blue: 0.64)
                          : Color.gray.opacity(0.25))
                    .frame(width: index == currentIndex ? 26 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
            }
        }
    }
}



// MARK: - ContentView (Onboarding)
struct ContentView: View {
    @State private var page = 0
    @State private var goHome = false   // لزر "ابدأ"

    var slides: [(String, AttributedString, String)] = [
        ("تواصل",
         AttributedString("شاهد فيديوهات لغة الإشارة مع وصف مكتوب يساعدك على فهم كل موقف بسهولة."),
         "person.2.fill"),

        ("وضوح",
         AttributedString("يسجل كلام الشخص أمامك ويعرضه مباشرة كنص واضح على الشاشة."),
         "mic.fill"),

        ("راحة وطمأنينة",
         makeLastSubtitle(),
         "heart.fill")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                MovingSoftBackground()
                
                VStack {
                    
                    // زر التخطي
                    HStack {
                        if page < slides.count - 1 {
                            Button("تخطي") {
                                withAnimation { page = slides.count - 1 }
                            }
                            .foregroundColor(Color(red: 0.40, green: 0.65, blue: 0.64))
                            .padding(.top, 20)
                            .padding(.leading, 36)
                        }
                        Spacer()
                    }
                    .environment(\.layoutDirection, .leftToRight)
                    
                    
                    // الشرائح
                    TabView(selection: $page) {
                        ForEach(0..<slides.count, id: \.self) { i in
                            OnboardSlide(
                                title: slides[i].0,
                                subtitle: slides[i].1,
                                iconName: slides[i].2
                            )
                            .tag(i)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    
                    // المؤشر
                    PageIndicator(count: slides.count, currentIndex: page)
                        .padding(.bottom, 24)
                    
                    
                    // ------ زر التالي / ابدأ ------
                    if page == slides.count - 1 {

                        NavigationLink("", destination: HomePage(), isActive: $goHome)

                        Button {
                            goHome = true
                        } label: {
                            Text("ابدأ")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.40, green: 0.65, blue: 0.64))
                                .frame(width: 300, height: 56)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
                        }
                        .padding(.bottom, 40)
                        
                    } else {
                        
                        Button {
                            withAnimation { page += 1 }
                        } label: {
                            Text("التالي")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.40, green: 0.65, blue: 0.64))
                                .frame(width: 300, height: 56)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
}



// MARK: - نص كلمة أمد
func makeLastSubtitle() -> AttributedString {
    var text = AttributedString("يوفّر لك ")
    text += "أمد".highlightedAMAD
    text += AttributedString(" تجربة تواصل مريحة لتتفاعل بثقة.")
    return text
}



// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
