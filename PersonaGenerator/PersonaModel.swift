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
    let name: String
    let headline: String
    let bio: String
    let birthdate: Date
    let email: String
    let phone: String
}

extension Persona {
    var record: CKRecord {
        let record = CKRecord(recordType: "Persona")
        
        record["name"] = name
        record["headline"] = headline
        record["bio"] = bio
        record["birthdate"] = birthdate
        record["email"] = email
        record["phone"] = phone
        return record
    }
}
