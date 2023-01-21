
//  PersonaModel.swift
//  Persona Generator
//
//  Created by Timothy Sonner on 12/21/22.
//

import SwiftUI
import CloudKit

struct Persona: Identifiable {
    var id: CKRecord.ID
    var recordID: CKRecord.ID?
    var title: String
    var image: UIImage
    var name: String
    var headline: String
    var bio: String
    var birthdate: Date
    var email: String
    var phone: String
    var images: [UIImage]
    var isFavorite: Bool
    var website: String
    
    init(recordID: CKRecord.ID?, title: String, image: UIImage, name: String, headline: String, bio: String, birthdate: Date, email: String, phone: String, images: [UIImage], isFavorite: Bool, website: String) {
        self.id = recordID ?? CKRecord.ID()
        self.recordID = recordID ?? CKRecord.ID()
        self.title = title
        self.image = image
        self.name = name
        self.headline = headline
        self.bio = bio
        self.birthdate = birthdate
        self.email = email
        self.phone = phone
        self.images = images
        self.isFavorite = isFavorite
        self.website = website
    }
}

extension Persona {
    var record: CKRecord {
        let record = CKRecord(recordType: "Persona")
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("image.png")
        if let imageData = image.pngData() {
            try? imageData.write(to: fileURL)
        }
        
        // Create a CKAsset from the file URL
        let imageAsset = CKAsset(fileURL: fileURL)
        
        var imagesAsset = [CKAsset]()
        for image in images {
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("image.png")
            if let imageData = image.pngData() {
                try? imageData.write(to: fileURL)
            }
            // Create a CKAsset from the file URL
            let imageAsset = CKAsset(fileURL: fileURL)
            imagesAsset.append(imageAsset)
        }
        record["title"] = title
        record["image"] = imageAsset
        record["name"] = name
        record["headline"] = headline
        record["bio"] = bio
        record["birthdate"] = birthdate
        record["email"] = email
        record["phone"] = phone
        record["images"] = imagesAsset
        record["isFavorite"] = isFavorite
        record["website"] = website
        return record
    }
}

extension Persona: Equatable {
    static func == (lhs: Persona, rhs: Persona) -> Bool {
        return lhs.recordID == rhs.recordID && lhs.title == rhs.title && lhs.isFavorite == rhs.isFavorite
    }
}
