import SwiftUI

struct CircleButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if UIImage(systemName: icon) != nil {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
            } else {
                Text(icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}


struct CcircleButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if UIImage(systemName: icon) != nil {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(.buttons)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
            } else {
                Text(icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(.buttons)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
