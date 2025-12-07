import SwiftUI
import Combine

class PlaceViewModel: ObservableObject {
    @Published var place: Place
    @Published var searchText: String = ""
    
    let favoritesId = UUID()

    // 👇 التعديل هنا: نستقبل اسم المكان
    init(placeName: String = "مستشفى") {
        
        // هنا نضع منطق تغيير البيانات حسب الاسم
        // (طبعاً لاحقاً بتجيبها من قاعدة بيانات، بس الآن نسويها يدوي)
        
        if placeName == "السوبرماركت" {
            let video1 = VideoItem(description: "أين الخضار؟", imageName: "demo3", isFavorite: false)
            let cat1 = PlaceCategory(name: "خضار", icon: "carrot.fill", items: [video1])
            let cat2 = PlaceCategory(name: "محاسبة", icon: "cart.fill", items: [video1])
            
            self.place = Place(name: "السوبرماركت", categories: [cat1, cat2])
            
        } else if placeName == "المواصلات العامة" {
            let video1 = VideoItem(description: "حجز تذكرة", imageName: "demo3", isFavorite: false)
            let cat1 = PlaceCategory(name: "قطار", icon: "tram.fill", items: [video1])
            
            self.place = Place(name: "المواصلات", categories: [cat1])
            
        } else {
            // الافتراضي (المستشفى)
            let video1 = VideoItem(description: "طريقة التسجيل", imageName: "demo1", isFavorite: false)
            let video2 = VideoItem(description: "غرفة الانتظار", imageName: "demo1", isFavorite: true)
            let receptionCategory = PlaceCategory(name: "استقبال", icon: "🏥", items: [video1, video2])
            let earCategory = PlaceCategory(name: "أذن", icon: "👂", items: [video1])
            
            self.place = Place(name: "مستشفى", categories: [receptionCategory, earCategory])
        }
    }
    
    // ... باقي الكود (favoriteVideos, allCategories, displayedCategories, toggleFavorite) نفسه ما يتغير ...
    var favoriteVideos: [VideoItem] {
        return place.categories.flatMap { $0.items }.filter { $0.isFavorite }
    }
    
    var allCategories: [PlaceCategory] {
        let favCategory = PlaceCategory(id: favoritesId, name: "المفضلة", icon: "", items: favoriteVideos)
        return (!favoriteVideos.isEmpty ? [favCategory] : []) + place.categories
    }
    
    var displayedCategories: [PlaceCategory] {
        if searchText.isEmpty {
            return allCategories
        } else {
            return allCategories.compactMap { category in
                let matchingVideos = category.items.filter {
                    $0.description.localizedCaseInsensitiveContains(searchText)
                }
                if matchingVideos.isEmpty { return nil }
                return PlaceCategory(id: category.id, name: category.name, icon: category.icon, items: matchingVideos)
            }
        }
    }

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
