//
//  ViewModel.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/4/23.
//

import CloudKit
import UIKit

class ViewModel: ObservableObject {
    // MARK: - Properties
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    
    @Published var personas: [Persona] = []
    
    func fetchPersonas() {
        // Fetch data from CloudKit here
        let query = CKQuery(recordType: "Persona", predicate: NSPredicate(value: true))
        privateDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 0) { (result) in
            switch result {
            case .success(let matchResults):
                DispatchQueue.main.async {
                    self.personas = matchResults.matchResults.compactMap { recordResult in
                        switch recordResult.1 {
                        case .success(let record):
                            guard let title = record["title"] as? String,
                                  let imageAsset = record["image"] as? CKAsset,
                                  let name = record["name"] as? String,
                                  let headline = record["headline"] as? String,
                                  let bio = record["bio"] as? String,
                                  let birthdate = record["birthdate"] as? Date,
                                  let email = record["email"] as? String,
                                  let phone = record["phone"] as? String,
                                  let images = record["images"] as? [CKAsset] else {
                                return nil
                            }
                            // Load the image from the CKAsset
                            let image = UIImage(contentsOfFile: imageAsset.fileURL!.path)
                            return Persona(recordID: record.recordID, title: title, image: image!, name: name, headline: headline, bio: bio, birthdate: birthdate, email: email, phone: phone, images: images)
                        case .failure(let error):
                            print(error)
                            return nil
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        print("Personas fetched")
        
        
    }
    
    func deletePersona(persona: Persona) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        privateDatabase.delete(withRecordID: persona.recordID!) { (recordID, error) in
            if error != nil {
                // Handle error
                print(error!)
            } else {
                // Remove the deleted record from the `personas` array
                self.personas.removeAll(where: { $0.recordID == recordID })
            }
        }
    }

}
