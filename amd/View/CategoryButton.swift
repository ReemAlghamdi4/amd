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
                    .font(.custom("IBMPlexSansArabic-Bold", size:16))
            
            }            .foregroundColor(.black)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                isSelected ? Color("filter").opacity(1.0) : Color("filter").opacity(0.6)
            )
            .glassEffect()
            .clipShape(Capsule())
           
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
