//
//  PersonaModel.swift
//  Persona Generator
//
//  Created by Timothy Sonner on 12/21/22.
//

import SwiftUI
import CloudKit

struct Persona {
    var recordID: CKRecord.ID?
    let title: String
    let image: UIImage
    let name: String
    let headline: String
    let bio: String
    let birthdate: Date
    let email: String
    let phone: String
    let images: [CKAsset]
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
