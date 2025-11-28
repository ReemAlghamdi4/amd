//
//  models.swift
//  amd
//
//  Created by Reem alghamdi on 07/06/1447 AH.
//

import Foundation

struct VideoItem: Identifiable {
    let id = UUID()         // معرف فريد يتولد تلقائياً لكل عنصر
    let description: String
    let imageName: String   // اسم الصورة أو ملف الفيديو
    var isFavorite: Bool    // هل هو مفضل؟ (خليناها var عشان تتغير)
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
