import SwiftUI

struct CategoryContainerView: View {
    let category: PlaceCategory
    @ObservedObject var viewModel: PlaceViewModel
    
    @State private var isExpanded: Bool = false
    
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
                            .rotationEffect(isExpanded ? .degrees(-90) : .degrees(0))
                    }
                }
            }
            .padding(.horizontal)
            
            // --- المحتوى ---
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(.gray))
                
                VStack {
                    if isExpanded {
                        // الوضع المفتوح
                        VStack(spacing: 20) {
                            ForEach(category.items) { video in
                                // 👇 2. هنا نربط زر القلب بالدالة الموجودة في الفيو مودل
                                VideoCardView(video: video, onFavoriteTapped: {
                                    viewModel.toggleFavorite(for: video.id)
                                })
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(20)
                        .transition(.opacity)
                        
                    } else {
                        // الوضع المغلق
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(category.items) { video in
                                    // 👇 2. ونفس الشيء هنا
                                    VideoCardView(video: video, onFavoriteTapped: {
                                        viewModel.toggleFavorite(for: video.id)
                                    })
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
