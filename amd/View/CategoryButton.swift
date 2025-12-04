import SwiftUI
struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.title3)
                Text(title)
                    .font(.custom("IBMPlexSansArabic-Bold", size: 16))
            }
            .foregroundColor(.black)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background {
                ZStack {
                    // 1. طبقة التمويه القوية (الأساس)
                    Capsule()
                        .fill(.ultraThinMaterial)

                    Capsule()
                        .fill(
                            isSelected
                            ? Color.filter.opacity(0.5) // زجاج ملون
                            : Color.white.opacity(0.7)     // زجاج شفاف (موية)
                        )
                }
            }
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            stops: [
                                .init(color: .filter.opacity(0.8), location: 0.0), // لمعة قوية فوق يسار
                                .init(color: .filter.opacity(0.2), location: 0.5),
                                .init(color: .filter, location: 1)               // يختفي تحت يمين
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5 // سمك الإطار
                    )
            )
        }
    }
}

#Preview {
    HStack {
        CategoryButton(title: "استقبال", icon: "🏥", isSelected:true, action: {})
        CategoryButton(title: "أذن", icon: "👂🏻", isSelected: false, action: {})
        CategoryButton(title: "أذن", icon: "👂🏻", isSelected: false, action: {})

    }
}
