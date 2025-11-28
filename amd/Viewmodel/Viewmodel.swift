import SwiftUI
import Combine

class PlaceViewModel: ObservableObject {
    @Published var place: Place
    // 1. متغير البحث (يرتبط بشريط البحث في الشاشة)
    @Published var searchText: String = ""
    
    let favoritesId = UUID()

    init() {
        // ... (نفس بياناتك الوهمية السابقة بدون تغيير) ...
        let video1 = VideoItem(description: "waiting", imageName: "demo1", isFavorite: false)
        let video2 = VideoItem(description: "غرفة الانتظار", imageName: "demo1", isFavorite: true)
        let receptionCategory = PlaceCategory(name: "استقبال", icon: "🏥", items: [video1, video2])
        let earCategory = PlaceCategory(name: "أذن", icon: "👂", items: [video1])
        
        self.place = Place(name: "مستشفى", categories: [receptionCategory, earCategory])
    }
    
    // المفضلة (نفس السابق)
    var favoriteVideos: [VideoItem] {
        return place.categories.flatMap { $0.items }.filter { $0.isFavorite }
    }
    
    // القائمة الكاملة (المفضلة + الباقي)
    var allCategories: [PlaceCategory] {
        let favCategory = PlaceCategory(id: favoritesId, name: "المفضلة", icon: "❤️", items: favoriteVideos)
        return (!favoriteVideos.isEmpty ? [favCategory] : []) + place.categories
    }
    
    // 2. القائمة النهائية (اللي نعرضها للشاشة)
    // وظيفتها: تشوف هل فيه بحث؟ إذا ايه، تفلتر. إذا لا، ترجع الكل.
    var displayedCategories: [PlaceCategory] {
        if searchText.isEmpty {
            return allCategories
        } else {
            // منطق الفلتر:
            // 1. ندخل على كل قسم.
            // 2. نشوف الفيديوهات اللي داخله، هل الاسم يحتوي على نص البحث؟
            // 3. إذا القسم صار فاضي بعد الفلتر، نحذفه.
            return allCategories.compactMap { category in
                let matchingVideos = category.items.filter {
                    $0.description.localizedCaseInsensitiveContains(searchText)
                }
                
                if matchingVideos.isEmpty { return nil }
                
                return PlaceCategory(
                    id: category.id,
                    name: category.name,
                    icon: category.icon,
                    items: matchingVideos
                )
            }
        }
    }

    // دالة المفضلة (نفس السابق)
    func toggleFavorite(for videoId: UUID) {
        for (i, cat) in place.categories.enumerated() {
            if let j = cat.items.firstIndex(where: { $0.id == videoId }) {
                place.categories[i].items[j].isFavorite.toggle()
                objectWillChange.send()
                return
            }
        }
    }
}
