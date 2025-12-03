import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = PlaceViewModel()
    @State private var selectedCategoryId: UUID?
    @Environment(\.dismiss) private var dismiss

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
                        // الأزرار الجديدة (يسار - شكل فقط)
                        HStack(spacing: 10) {
                            CircleButton(icon: "plus") { }
                            CircleButton(icon: "mic") { }
                        }
                        
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    HStack {
                                            Text(viewModel.place.name)
                                                .font(.custom("IBMPlexSansArabic-Bold", size: 34))
                                            Spacer() // يدف النص لليمين
                    }                    .padding(.leading, 12)

                    // ب. شريط البحث
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("الاذن", text: $viewModel.searchText)
                            .font(.custom("IBMPlexSansArabic-Regular", size: 16))
                            .textFieldStyle(.plain)
                    }
                    .padding(12)
                    .background(Color(.gray))
                    .cornerRadius(17)
                    .padding(.horizontal)
                    
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
                            .glassEffect()

                            .padding(.horizontal)
                        }
                    }
                }

                Spacer()
                
                // --- 2. الجزء السفلي (القائمة) ---
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 25) {
                            
                            // 👇 التغيير هنا: نستخدم displayedCategories عشان البحث يشتغل
                            ForEach(viewModel.displayedCategories) { category in
                                CategoryContainerView(category: category, viewModel: viewModel)
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
        }
    }
}

// --- تصميم الأزرار الدائرية العلوية ---
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
