import SwiftUI

struct CategoryContainerView: View {
    let category: PlaceCategory
    @ObservedObject var viewModel: PlaceViewModel
    
    @State private var isExpanded: Bool = false
    
    // هذا المتغير اللي راح يرسل الفيديو للصفحة الرئيسية
    var onVideoSelect: (VideoItem) -> Void

    var body: some View {
        VStack(spacing: 15) {
            
            // --- العنوان وزر التوسيع ---
            HStack {
                Text(category.name)
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.orange)
                            .rotationEffect(isExpanded ? .degrees(90) : .degrees(0))
                    }
                }
            }
            .padding(.horizontal)
            
            // --- المحتوى ---
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial) // 1. خامة الزجاج الضبابية
                                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5) // 2. ظل ناعم يرفعه عن الخلفية
                                        .overlay(
                                            // 3. الإطار اللامع (تأثير انعكاس الضوء)
                                            RoundedRectangle(cornerRadius: 25)
                                                .strokeBorder(
                                                    LinearGradient(
                                                        stops: [
                                                            .init(color: .filter.opacity(0.6), location: 0.0), // لمعة قوية بالزاوية اليسرى فوق
                                                            .init(color: .filter.opacity(0.1), location: 0.4),
                                                            .init(color: .filter.opacity(0.0), location: 1.0)  // تختفي تحت يمين
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1.5
                                                )
                                        )
                VStack {
                    if isExpanded {
                        // 1. الوضع المفتوح (VStack)
                        VStack(spacing: 20) {
                            ForEach(category.items) { video in
                                VideoCardView(video: video, onFavoriteTapped: {
                                    viewModel.toggleFavorite(for: video.id)
                                })
                                .frame(maxWidth: .infinity)
                                // 👇 التعديل الأول: إضافة الضغط هنا
                                .onTapGesture {
                                    onVideoSelect(video)
                                }
                            }
                        }
                        .padding(20)
                        .transition(.opacity)
                        
                    } else {
                        // 2. الوضع المغلق (ScrollView)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(category.items) { video in
                                    VideoCardView(video: video, onFavoriteTapped: {
                                        viewModel.toggleFavorite(for: video.id)
                                    })
                                    // 👇 التعديل الثاني: إضافة الضغط هنا أيضاً
                                    .onTapGesture {
                                        onVideoSelect(video)
                                    }
                                }
                            }
                            .padding(20)
                        }
                        .transition(.opacity)
                    }
                }
            }
            .frame(height: isExpanded ? nil : 220)
            .padding(.horizontal)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
