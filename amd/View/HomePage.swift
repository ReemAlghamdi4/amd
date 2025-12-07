//
//  HomePage.swift
//  amd
//
//  Created by Norah Aldawsari on 01/12/2025.
//

import SwiftUI

// Color helpers
extension Color {
    static let tealButton = Color(hex: "#62A1A0")
    static let lightTeal = Color(hex: "#BFECE8")
    static let orangeText = Color(hex: "#FF914D")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct WheelOption: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
}

let wheelOptions: [WheelOption] = [
    .init(icon: "❤️", label: "المفضلة"),
    .init(icon: "🛒", label: "السوبرماركت"),
    .init(icon: "🚑", label: "مستشفى"),
    .init(icon: "🪑", label: "المواصلات العامة")
]

struct HomePage: View {
    @State private var selectedIndex = 1 // Center by default
    @State private var goToHomeView = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Use the onboarding background here
                MovingSoftBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top left avatar button
                    HStack {
                        Button(action: {}) {
                            ZStack {
                                Circle()
                                    .fill(Color.tealButton)
                                    .frame(width: 36, height: 36)
                                Text("🌟")
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.leading, 36)
                        .padding(.top, 16)

                        Spacer()
                    }

                    Spacer().frame(height: 160)
                    
                    // Main greeting text
                    VStack(alignment:.trailing, spacing: 6) {
                        HStack(spacing: 6) {
                            Text("👋🏻")
                                .font(.system(size: 32))
                            Text("أهلًا")
                                .font(.custom("IBMPlexSansArabic-Bold", size: 34))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)

                        HStack(spacing: 2) {
                            Text("نقدر نساعدك")
                                .font(.custom("IBMPlexSansArabic-Bold", size: 34))
                                .foregroundColor(.black)
                            
                            Text("وين")
                                .font(.custom("IBMPlexSansArabic-Bold", size: 34))
                                .foregroundColor(.orangeText)
                                .padding(.leading, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)

                        Text("اليوم؟")
                            .font(.custom("IBMPlexSansArabic-Bold", size: 34))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 30)
                    .padding(.trailing, 12)

                    Spacer()

                    // Wheel selector
                    WheelSelector(selectedIndex: $selectedIndex)
                        .padding(.bottom, 40)

                    // Next button
                    Button(action: {
                        goToHomeView = true
                    }) {
                        Text("التالي")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(
                                Capsule()
                                    .fill(Color.tealButton)
                            )
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 32)
                }
            }
            // Navigation destination to HomeView
            .navigationDestination(isPresented: $goToHomeView) {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// Removed BackgroundBlobs; not needed anymore.

struct WheelSelector: View {
    @Binding var selectedIndex: Int
    
    // Gesture state
    @State private var dragOffset: CGFloat = 0
    @State private var currentIndexFloat: CGFloat = 1 // starts centered on item 1
    
    // Tuning constants to match the design
    private let cardSize = CGSize(width: 140, height: 120) // center size
    private let sideCardSize = CGSize(width: 120, height: 104)
    private let spacing: CGFloat = 30 // logical spacing between items along the wheel
    private let perspective: CGFloat = 0.8
    private let maxTiltDegrees: Double = 18
    private let sideYOffset: CGFloat = 16
    private let centerShadow = Color.black.opacity(0.15)
    private let sideShadow = Color.black.opacity(0.05)
    
    private var totalItems: Int { wheelOptions.count }
    
    var body: some View {
        GeometryReader { geo in
            let availableWidth = geo.size.width
            let itemStride = spacing + sideCardSize.width
            let centerX = availableWidth / 2
            
            ZStack {
                ForEach(wheelOptions.indices, id: \.self) { idx in
                    let delta = CGFloat(idx) - currentIndexFloat
                    let isCenter = abs(delta) < 0.5
                    
                    let x = centerX + delta * itemStride
                    
                    let scale = isCenter ? 1.0 : max(0.9, 1.0 - 0.08 * abs(delta))
                    let opacity = isCenter ? 1.0 : max(0.25, 1.0 - 0.55 * abs(delta))
                    let yOffset = isCenter ? 0 : sideYOffset * min(1, abs(delta))
                    
                    let clampedDelta = max(-1, min(1, delta))
                    let tilt = -maxTiltDegrees * Double(clampedDelta)
                    
                    let size = isCenter ? cardSize : sideCardSize
                    
                    VStack(spacing: 12) {
                        Text(wheelOptions[idx].icon)
                            .font(.system(size: 28))
                        Text(wheelOptions[idx].label)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(isCenter ? .white : Color.black.opacity(0.25))
                    }
                    .frame(width: size.width, height: size.height)
                    .background(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(isCenter ? Color.tealButton : Color.white)
                            .shadow(color: isCenter ? centerShadow : sideShadow,
                                    radius: isCenter ? 20 : 8,
                                    x: 0, y: isCenter ? 12 : 4)
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotation3DEffect(.degrees(tilt), axis: (x: 0, y: 1, z: 0), perspective: perspective)
                    .position(x: x, y: geo.size.height / 2 + yOffset)
                    .zIndex(isCenter ? 10 : Double(10 - abs(delta)))
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            currentIndexFloat = CGFloat(idx)
                            selectedIndex = idx
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 3, coordinateSpace: .local)
                    .onChanged { value in
                        let itemStridePx = itemStride
                        let deltaIndex = -value.translation.width / itemStridePx
                        let minIndex: CGFloat = 0
                        let maxIndex: CGFloat = CGFloat(totalItems - 1)
                        let newFloat = max(minIndex, min(maxIndex, CGFloat(selectedIndex) + deltaIndex))
                        currentIndexFloat = newFloat
                    }
                    .onEnded { value in
                        let itemStridePx = itemStride
                        let deltaIndex = -value.translation.width / itemStridePx
                        let minIndex: CGFloat = 0
                        let maxIndex: CGFloat = CGFloat(totalItems - 1)
                        var target = CGFloat(selectedIndex) + deltaIndex
                        target = round(target)
                        target = max(minIndex, min(maxIndex, target))
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            currentIndexFloat = target
                            selectedIndex = Int(target)
                        }
                    }
            )
            .onChange(of: selectedIndex) { _, newValue in
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentIndexFloat = CGFloat(newValue)
                }
            }
            .onAppear {
                currentIndexFloat = CGFloat(selectedIndex)
            }
        }
        .frame(height: 150)
        .animation(.easeInOut(duration: 0.25), value: selectedIndex)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    HomePage()
}
