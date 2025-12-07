import SwiftUI

struct HomeView: View {
    // نستخدم StateObject مع تهيئة مخصصة
    @StateObject var viewModel: PlaceViewModel
    @State private var selectedCategoryId: UUID?
    @State private var selectedVideo: VideoItem?
    
    @Environment(\.dismiss) private var dismiss

    // 👇 دالة Init مخصصة لاستقبال الاسم من الصفحة السابقة
    init(placeName: String = "مستشفى") {
        _viewModel = StateObject(wrappedValue: PlaceViewModel(placeName: placeName))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                VStack(spacing: 15) {
                    
                    // أ. العنوان والأزرار العلوية
                    HStack {
                        CircleButton(icon:"chevron.backward") {
                            dismiss()
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            CircleButton(icon: "plus") { }
                            CircleButton(icon: "mic") { }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // العنوان
                    HStack {
                        Text(viewModel.place.name)
                            .font(.custom("IBMPlexSansArabic-Bold", size: 34))
                        Spacer()
                    }
                    .padding(.leading, 12)

                    // ب. شريط البحث
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("بحث في \(viewModel.place.name)...", text: $viewModel.searchText)
                            .font(.custom("IBMPlexSansArabic-Regular", size: 16))
                            .textFieldStyle(.plain)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.15)) // تعديل بسيط للون
                    .clipShape(RoundedRectangle(cornerRadius: 17))
                    .overlay(
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(
                                LinearGradient(
                                    stops: [
                                        .init(color: Color("filter").opacity(0.8), location: 0.0),
                                        .init(color: Color("filter").opacity(0.2), location: 0.5),
                                        .init(color: Color("filter"), location: 1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .padding(.horizontal)
                    
                    // ج. الفلتر
                    if viewModel.searchText.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.displayedCategories) { category in
                                    CategoryButton(
                                        title: category.name,
                                        icon: category.icon,
                                        isSelected: selectedCategoryId == category.id
                                    ) {
                                        selectedCategoryId = category.id
                                    }
                                }
                            }
                            .padding(.horizontal)
                     
                        }
                    }
                }

                Spacer()
                
                // --- 2. الجزء السفلي (القائمة) ---
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 25) {
                            
                            ForEach(viewModel.displayedCategories) { category in
                                CategoryContainerView(
                                    category: category,
                                    viewModel: viewModel,
                                    onVideoSelect: { video in // ✅ تم توحيد الاسم ليكون onVideoTap
                                        selectedVideo = video
                                    }
                                )
                                .id(category.id)
                            }
                            
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 50)
                        
                        .onChange(of: selectedCategoryId) { oldValue, newValue in
                            if let targetId = newValue {
                                withAnimation {
                                    proxy.scrollTo(targetId, anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .onAppear {
                if selectedCategoryId == nil {
                    selectedCategoryId = viewModel.displayedCategories.first?.id
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(item: $selectedVideo) { video in
                PlayerVideo(video: video, viewModel: viewModel)
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    HomeView(placeName: "مستشفى")
}
