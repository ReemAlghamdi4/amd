import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = PlaceViewModel()
    @State private var selectedCategoryId: UUID?
    @State private var selectedVideo: VideoItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                VStack(spacing: 14) {
                    HStack {
                        CircleButton(icon:"chevron.backward") { dismiss() }
                        Spacer()
                        HStack(spacing: 10) {
                            CircleButton(icon: "plus") { }
                            CircleButton(icon: "mic") { }
                        }
                    }
                    .padding(.top, 10)

                    HStack {
                        Text(viewModel.place.name)
                            .font(.custom("IBMPlexSansArabic-Bold", size: 34))
                        Spacer()
                    }
                    

                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("الاذن", text: $viewModel.searchText)
                            .font(.custom("IBMPlexSansArabic-Regular", size: 16))
                            .textFieldStyle(.plain)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 17))
                    .overlay(
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(
                                LinearGradient(
                                    stops: [
                                        .init(color: .filter.opacity(0.8), location: 0.0),
                                        .init(color: .filter.opacity(0.2), location: 0.5),
                                        .init(color: .filter, location: 1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .background(Color(.white))
                    .cornerRadius(20)
                    
            
                
                }
                .padding(.horizontal, 20)
                

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

                        .padding(.horizontal, 24)
                    }
                }
            

            Spacer()
            
            ScrollView(.vertical, showsIndicators: false) {
                
                    ScrollViewReader { proxy in
                        VStack(spacing: 25) {
                            
                            ForEach(viewModel.displayedCategories) { category in
                                CategoryContainerView(category: category, viewModel: viewModel,
                            onVideoSelect: { video in   // 👈 نضيف هذا الباراميتر
                            self.selectedVideo = video
                                                              }
                                
                                )
                                    .id(category.id)
                            }
                            
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 50)
                        .padding(.horizontal, 8)

                        
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
        }

                .sheet(item: $selectedVideo) { video in
                    PlayerVideo(video: video, viewModel: viewModel)
                        .presentationDragIndicator(.visible)
                }
            }
        }


struct CircleButton: View {
    let icon: String
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white) // اللون السماوي
                .padding(10)
                .background(.buttons) // خلفية شفافة
                .clipShape(Circle())
                .glassEffect()
        }
    }
}

#Preview {
    HomeView()
}
