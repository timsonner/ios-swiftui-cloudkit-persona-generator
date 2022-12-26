//
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
        var images: [CKAsset]
        
        init(recordID: CKRecord.ID?, title: String, image: UIImage, name: String, headline: String, bio: String, birthdate: Date, email: String, phone: String, images: [CKAsset]) {
            self.id = recordID ?? CKRecord.ID()
            self.recordID = recordID
            self.title = title
            self.image = image
            self.name = name
            self.headline = headline
            self.bio = bio
            self.birthdate = birthdate
            self.email = email
            self.phone = phone
            self.images = images
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
        
        record["title"] = title
        record["image"] = imageAsset
        record["name"] = name
        record["headline"] = headline
        record["bio"] = bio
        record["birthdate"] = birthdate
        record["email"] = email
        record["phone"] = phone
        record["images"] = images
        return record
    }
}
