import SwiftUI

struct HomeView: View {
    @State private var showSmartAssistant = false
    @StateObject var viewModel: PlaceViewModel
    @State private var selectedCategoryId: UUID?
    @State private var selectedVideo: VideoItem?
    
    // Animation states
    @State private var isAnimating = false
    @State private var isBreathing = false
    @Environment(\.dismiss) private var dismiss

    init(placeName: String = "مستشفى") {
        _viewModel = StateObject(wrappedValue: PlaceViewModel(placeName: placeName))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // MARK: - Header Section
                // I removed the extra nested VStack/HStack here for cleaner layout
                HStack {
                    CcircleButton(icon: "chevron.backward") {
                        dismiss()
                    }
                    
                    Spacer()
                    
                    // --- Mic Animation Button ---
                    // Keep it fixed-size and rotate around center so it doesn't move
                    ZStack {
                        Color.clear
                            .frame(width: 35, height: 35)
                        
                        Image("micc")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            // Breathing (pulsing) scale — slower and softer
                            .scaleEffect(isBreathing ? 1.09 : 1.0)
                            // Opacity breath in sync with scale
                            .opacity(isBreathing ? 1.0 : 0.7)
                            .animation(
                                .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                                value: isBreathing
                            )
                            // Spinning — gentle
                            .rotationEffect(.degrees(isAnimating ? 360 : 0), anchor: .center)
                            .animation(
                                isAnimating
                                ? .linear(duration: 10.0).repeatForever(autoreverses: false)
                                : .none,
                                value: isAnimating
                            )
                        
                        CcircleButton(icon: "mic") {
                            showSmartAssistant = true
                        }
                    }
                    .onAppear {
                        // Defer to the next runloop so layout is stable before animation starts
                        DispatchQueue.main.async {
                            isAnimating = true
                            isBreathing = true
                        }
                    }
                }

                .padding(.horizontal)
                .padding(.top, 10)
                
                // MARK: - Title Section
                HStack {
                    Text(viewModel.place.name)
                        .font(.custom("IBMPlexSansArabic-Bold", size: 34))
                    Spacer()
                }
                .padding(.leading, 12)

                // MARK: - Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("بحث في \(viewModel.place.name)...", text: $viewModel.searchText)
                        .font(.custom("IBMPlexSansArabic-Regular", size: 16))
                        .textFieldStyle(.plain)
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
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
                
                // MARK: - Categories (Horizontal Scroll)
                if viewModel.searchText.isEmpty && !viewModel.isLoading {
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
                
                // MARK: - Main Content Area
                if viewModel.isLoading {
                    VStack(spacing: 15) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.gray)
                        Text("جاري تحميل المقاطع...")
                            .font(.custom("IBMPlexSansArabic-Regular", size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if viewModel.displayedCategories.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("لا توجد مقاطع متاحة")
                            .font(.custom("IBMPlexSansArabic-Bold", size: 18))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            VStack(spacing: 25) {
                                ForEach(viewModel.displayedCategories) { category in
                                    CategoryContainerView(
                                        category: category,
                                        viewModel: viewModel,
                                        onVideoSelect: { video in
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
            }
            .environment(\.layoutDirection, .rightToLeft) // RTL Setting
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
