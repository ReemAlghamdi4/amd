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
                
                var fetchedVideos: [VideoItem] = []
                
                for match in matchResults.matchResults {
                    if let record = try? match.1.get() {
                        let title = record["title"] as? String ?? "بدون عنوان"
                        let category = record["category"] as? String ?? "عام"
                        let details = record["details"] as? String ?? ""
                        
                        // isFavorite could be Bool or Number in CloudKit. Try both safely.
                        var isFav = false
                        if let favBool = record["isFavorite"] as? Bool {
                            isFav = favBool
                        } else if let favNum = record["isFavorite"] as? Int64 {
                            isFav = (favNum == 1)
                        } else if let favNumInt = record["isFavorite"] as? Int {
                            isFav = (favNumInt == 1)
                        }
                        
                        // Read the asset with the correct case-sensitive key: "VideoAsset"
                        var localVideoURL: URL?
                        if let asset = record["VideoAsset"] as? CKAsset {
                            let assetURL = asset.fileURL
                            print("🔗 CKAsset fileURL (raw): \(assetURL?.path ?? "nil")")
                            
                            if let assetURL = assetURL {
                                // Ensure local persistence: copy to Caches/videos/<recordID>.mov
                                localVideoURL = self.copyAssetToCaches(assetURL: assetURL, recordID: record.recordID)
                                if let finalURL = localVideoURL {
                                    let exists = FileManager.default.fileExists(atPath: finalURL.path)
                                    let size = (try? FileManager.default.attributesOfItem(atPath: finalURL.path)[.size] as? NSNumber)?.int64Value ?? -1
                                    print("📁 Local copied URL: \(finalURL.path), exists: \(exists), size: \(size) bytes")
                                } else {
                                    print("⚠️ Failed to copy asset to caches for record: \(record.recordID.recordName)")
                                }
                            } else {
                                print("⚠️ CKAsset had nil fileURL for record: \(record.recordID.recordName)")
                            }
                        } else {
                            print("⚠️ لم يتم العثور على الحقل 'VideoAsset' أو ليس CKAsset في السجل: \(record.recordID.recordName)")
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
    
    // Copy CKAsset temp file to a stable location inside Caches/videos
    // Force .mov extension so AVFoundation recognizes the container and avoids -12847 errors.
    private func copyAssetToCaches(assetURL: URL, recordID: CKRecord.ID) -> URL? {
        do {
            let caches = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let videosDir = caches.appendingPathComponent("videos", isDirectory: true)
            if !FileManager.default.fileExists(atPath: videosDir.path) {
                try FileManager.default.createDirectory(at: videosDir, withIntermediateDirectories: true)
            }
            // Force .mov since your uploads are MOV files
            let dest = videosDir.appendingPathComponent("\(recordID.recordName).mov")
            
            // If already exists, replace to ensure freshness
            if FileManager.default.fileExists(atPath: dest.path) {
                try? FileManager.default.removeItem(at: dest)
            }
            
            // Prefer robust copy: read data then write, to ensure the file is materialized
            let data = try Data(contentsOf: assetURL, options: [.mappedIfSafe])
            try data.write(to: dest, options: [.atomic])
            
            return dest
        } catch {
            print("❌ copyAssetToCaches error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getIconForCategory(_ name: String) -> String {
        if name.contains("أذن وانف وحنجره") { return "👃🏻👂🏻" }
        if name.contains("استقبال") { return "📁" }
        if name.contains("طوارئ") { return "🚨" }
        if name.contains("عام") { return "🩺" }
        if name.contains("اسنان") { return "🦷" }

        return "folder.fill"
    }

    var favoriteVideos: [VideoItem] {
        return place.categories.flatMap { $0.items }.filter { $0.isFavorite }
    }
    
    var allCategories: [PlaceCategory] {
        let favCategory = PlaceCategory(id: favoritesId, name: "المفضلة", icon: "heart.fill", items: favoriteVideos)
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
