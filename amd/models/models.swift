//
//  models.swift
//  amd
//
//  Created by Reem alghamdi on 07/06/1447 AH.
//

import Foundation
import CloudKit

struct VideoItem: Identifiable {
    let id = UUID()
    let title: String        // 👈 العنوان القصير (يظهر في الكرت)
    let details: String      // 👈 الوصف الطويل (يظهر تحت الفيديو)
    let videoURL: URL?
    var isFavorite: Bool
    let categoryName: String
}
struct PlaceCategory: Identifiable {
    let id: UUID // شلنا = UUID() عشان نقدر نتحكم فيه
    let name: String
    let icon: String
    var items: [VideoItem]

    init(id: UUID = UUID(), name: String, icon: String, items: [VideoItem]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.items = items
    }
}
struct Place: Identifiable {
    let id = UUID()
    let name: String
    var categories: [PlaceCategory]
}
