import SwiftUI

struct HomeView: View {
    @State private var showSmartAssistant = false
    // نستخدم StateObject مع تهيئة مخصصة
    @StateObject var viewModel: PlaceViewModel
    @State private var selectedCategoryId: UUID?
    @State private var selectedVideo: VideoItem?
    
    // Animation states for mic background
    @State private var isPulsing = false
    @State private var rotationAngle: Double = 0
    
    @Environment(\.dismiss) private var dismiss

    init(placeName: String = "مستشفى") {
        _viewModel = StateObject(wrappedValue: PlaceViewModel(placeName: placeName))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                VStack(spacing: 15) {
                    
                    // أ. العنوان والأزرار العلوية
                    HStack {
                        CcircleButton(icon:"chevron.backward") {
                            dismiss()
                        }
                        Spacer()
                        HStack(spacing: 10) {
                           // CcircleButton(icon: "plus") { }
                            ZStack {
                                // الخلفية المتحركة
                                Image("micc")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 38, height: 38)
                                // التعديل هنا: حركة تكبير وتصغير بسيطة جداً
                                    .scaleEffect(isPulsing ? 1.1 : 0.95)
                                // التعديل هنا: تغيير الشفافية ليعطي شعور الظهور والاختفاء
                                    .opacity(isPulsing ? 1.0 : 0.6)
                                    .onAppear {
                                        // التعديل هنا: زدنا الوقت لـ 3 ثواني لتكون الحركة بطيئة ومريحة
                                        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                                            isPulsing.toggle()
                                        }
                                    }
                                
                                CcircleButton(icon: "mic") {
                                    showSmartAssistant = true
                                }
                            }
                            
                            
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
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
        .fullScreenCover(isPresented: $showSmartAssistant) {
            SmartAssistantView()
        }

    }
}

#Preview {
    HomeView(placeName: "مستشفى")
}
