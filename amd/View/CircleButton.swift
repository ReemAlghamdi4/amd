import SwiftUI

// Cross‑platform SF Symbol availability check without importing UIKit globally.
private func isValidSFSymbol(_ name: String) -> Bool {
    #if os(iOS) || os(tvOS) || os(watchOS)
    // UIKit is available here, but we don't need a top-level import; SwiftUI re-exports it on these platforms.
    return UIImage(systemName: name) != nil
    #elseif os(macOS)
    return NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil
    #else
    // Fallback: assume valid
    return true
    #endif
}

struct CircleButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if isValidSFSymbol(icon) {
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
            if isValidSFSymbol(icon) {
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
