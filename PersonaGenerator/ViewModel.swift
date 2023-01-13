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
    @Published var persona: Persona?
    @Published var isLoading: Bool = false
    @Published var isEditPersonaViewPresented: Bool = false
    @Published var error: String = "Fuuuuck"
    @Published var isAlertPresented = true
    
    func fetchPersonas() {
        // Fetch data from CloudKit here
        self.isLoading = true
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
                            
                            self.isLoading = false
                            
                            return Persona(recordID: record.recordID, title: title, image: image!, name: name, headline: headline, bio: bio, birthdate: birthdate, email: email, phone: phone, images: images)
                            
                        case .failure(let error):
                            self.error = error.localizedDescription
                            self.isAlertPresented = true
                            print(error)
                            return nil
                        }
                    }
                }
            case .failure(let error):
                self.error = error.localizedDescription
                self.isAlertPresented = true
                print(error)
            }
        }
    }
    
    func deletePersona(persona: Persona) {
        privateDatabase.delete(withRecordID: persona.recordID!) { (recordID, error) in
            if error != nil {
                // Handle error
                self.error = error!.localizedDescription
                self.isAlertPresented = true
                print(error!)
            } else {
                // Remove the deleted record from the `personas` array
                DispatchQueue.main.async {
                    self.personas.removeAll(where: { $0.recordID == recordID })
                }
            }
        }
    }
    
    func updatePersona(images: [UIImage], image: UIImage?, title: String, name: String, headline: String, bio: String, birthdate: Date, email: String, phone: String, recordID: CKRecord.ID) {
        
        self.isLoading = true
        var imageAssetArray: [CKAsset] = []
        
        for image in images {
            imageAssetArray.append(image.convertToCKAsset()!)
        }
        let imageAsset = image?.convertToCKAsset()
        // Retrieve the existing record from CloudKit
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let recordID = recordID
        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                self.error = error.localizedDescription
                self.isAlertPresented = true
                print(error)
                return
            }
            
            guard let record = record else {
                self.error = "Error creating record"
                self.isAlertPresented = true
                print("Error creating record")
                return
            }
            
            // Modify the record's properties
            record["images"] = imageAssetArray
            record["image"] = imageAsset
            record["title"] = title
            record["name"] = name as CKRecordValue
            record["headline"] = headline as CKRecordValue
            record["bio"] = bio as CKRecordValue
            record["birthdate"] = birthdate as CKRecordValue
            record["email"] = email as CKRecordValue
            record["phone"] = phone as CKRecordValue
            
            privateDatabase.save(record) { (savedRecord, error) in
                if error != nil {
                    self.error = error!.localizedDescription
                    self.isAlertPresented = true
                    print(error as Any)
                } else {
                    DispatchQueue.main.async {
                        self.persona?.recordID = savedRecord?.recordID
                        self.isLoading = false
                    }
                }
            }
        }
    } // updatePersona
    
    func createPersona(record: Persona) {
        self.isLoading = true
        privateDatabase.save(record.record) { (savedRecord, error) in
            
            if error != nil {
                self.error = error!.localizedDescription
                self.isAlertPresented = true
                print("Record Not Saved")
                print(error as Any)
            } else {
                print("Record Saved")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
