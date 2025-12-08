import SwiftUI
import CloudKit
import Combine

class PlaceViewModel: ObservableObject {
    @Published var place: Place
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    let container = CKContainer.default()
    let database = CKContainer.default().publicCloudDatabase
    let favoritesId = UUID()
    
    // 👇 مفتاح حفظ المفضلة في الجهاز
    private let favoritesKey = "UserFavoritesList"

    init(placeName: String = "مستشفى") {
        self.place = Place(name: placeName, categories: [])
        fetchVideosFromCloud(placeName: placeName)
    }
    
    func fetchVideosFromCloud(placeName: String) {
        isLoading = true
        print("📡 جاري البحث عن فيديوهات للمكان: \(placeName)")
        
        let predicate = NSPredicate(format: "place == %@", placeName)
        let query = CKQuery(recordType: "videos", predicate: predicate)
        
        database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 100) { result in
            switch result {
            case .success(let matchResults):
                print("✅ تم العثور على \(matchResults.matchResults.count) فيديو")
                
                // 👇 1. نجيب قائمة المفضلة المحفوظة محلياً في جوال المستخدم
                let savedFavorites = UserDefaults.standard.stringArray(forKey: self.favoritesKey) ?? []
                
                var fetchedVideos: [VideoItem] = []
                
                for match in matchResults.matchResults {
                    if let record = try? match.1.get() {
                        let title = record["title"] as? String ?? "بدون عنوان"
                        let category = record["category"] as? String ?? "عام"
                        let details = record["details"] as? String ?? ""
                        
                        // 👇 2. نعتمد على الحفظ المحلي لتحديد المفضلة، وليس الكلاود
                        // لأن الكلاود يعطي قيمة عامة للجميع، بينما المفضلة شخصية
                        let isFav = savedFavorites.contains(title)
                        
                        // معالجة الفيديو (نسخ للكاش)
                        var localVideoURL: URL?
                        // تأكدنا من اسم الحقل "videoAsset" (أول حرف صغير عادة في كلاود كيت إلا لو سميته Capital)
                        // سأضع احتمالات لضمان العمل
                        let assetAny = record["videoAsset"] ?? record["VideoAsset"]
                        
                        if let asset = assetAny as? CKAsset {
                            let assetURL = asset.fileURL
                            
                            if let assetURL = assetURL {
                                // نسخ الملف لمجلد الكاش لضمان بقائه وتشغيله
                                localVideoURL = self.copyAssetToCaches(assetURL: assetURL, recordID: record.recordID)                            }
                        }
                        
                        let video = VideoItem(
                            title: title,
                            details: details,
                            videoURL: localVideoURL,
                            isFavorite: isFav,
                            categoryName: category
                        )
                        fetchedVideos.append(video)
                    }
                }
                
                // تجميع وترتيب الأقسام
                let groupedDictionary = Dictionary(grouping: fetchedVideos, by: { $0.categoryName })
                
                let newCategories = groupedDictionary.map { (key, videos) -> PlaceCategory in
                    let icon = self.getIconForCategory(key)
                    return PlaceCategory(name: key, icon: icon, items: videos)
                }.sorted { $0.name < $1.name }
                
                DispatchQueue.main.async {
                    self.place.categories = newCategories
                    self.isLoading = false
                }
                
            case .failure(let error):
                print("❌ خطأ في السحب: \(error.localizedDescription)")
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }
    
    // دالة نسخ الملفات للكاش (كودك الممتاز)
    private func copyAssetToCaches(assetURL: URL, recordID: CKRecord.ID) -> URL? {
        do {
            let caches = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let videosDir = caches.appendingPathComponent("videos", isDirectory: true)
            if !FileManager.default.fileExists(atPath: videosDir.path) {
                try FileManager.default.createDirectory(at: videosDir, withIntermediateDirectories: true)
            }
            // إجبار الصيغة .mov لتفادي مشاكل AVPlayer
            let dest = videosDir.appendingPathComponent("\(recordID.recordName).mov")
            
            // إذا الملف موجود، نحذفه ونستبدله لضمان التحديث
            if FileManager.default.fileExists(atPath: dest.path) {
                try? FileManager.default.removeItem(at: dest)
            }
            
            // النسخ الآمن
            let data = try Data(contentsOf: assetURL, options: [.mappedIfSafe])
            try data.write(to: dest, options: [.atomic])
            
            return dest
        } catch {
            print("❌ copyAssetToCaches error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getIconForCategory(_ name: String) -> String {
        if name.contains("أذن") { return "👃🏻👂🏻" }
        if name.contains("استقبال") { return "📁" }
        if name.contains("طوارئ") { return "🚨" }
        if name.contains("عام") { return "🩺" }
        if name.contains("اسنان") { return "🦷" }
        if name.contains("اسنان") { return "🦷" }
        return "🥼"
    }

    var favoriteVideos: [VideoItem] {
        return place.categories.flatMap { $0.items }.filter { $0.isFavorite }
    }
    
    var allCategories: [PlaceCategory] {
        let favCategory = PlaceCategory(id: favoritesId, name: "المفضلة", icon: "❤️", items: favoriteVideos)
        return (!favoriteVideos.isEmpty ? [favCategory] : []) + place.categories
    }
    
    var displayedCategories: [PlaceCategory] {
        if searchText.isEmpty {
            return allCategories
        } else {
            return allCategories.compactMap { category in
                let matchingVideos = category.items.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText)
                }
                if matchingVideos.isEmpty { return nil }
                return PlaceCategory(id: category.id, name: category.name, icon: category.icon, items: matchingVideos)
            }
        }
    }

    // 👇 دالة التبديل مع الحفظ في الذاكرة
    func toggleFavorite(for videoId: UUID) {
        for (i, cat) in place.categories.enumerated() {
            if let j = cat.items.firstIndex(where: { $0.id == videoId }) {
                // عكس الحالة في الذاكرة الحالية
                place.categories[i].items[j].isFavorite.toggle()
                
                let video = place.categories[i].items[j]
                
                // 👇 حفظ التغيير في ذاكرة الجهاز الدائمة
                updateLocalFavorites(videoTitle: video.title, isFavorite: video.isFavorite)
                
                objectWillChange.send()
                return
            }
        }
    }
    
    // 👇 دالة مساعدة لإدارة UserDefaults
    private func updateLocalFavorites(videoTitle: String, isFavorite: Bool) {
        var savedFavorites = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        
        if isFavorite {
            if !savedFavorites.contains(videoTitle) {
                savedFavorites.append(videoTitle)
            }
        } else {
            savedFavorites.removeAll { $0 == videoTitle }
        }
        
        UserDefaults.standard.set(savedFavorites, forKey: favoritesKey)
    }
}
