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
    
    @Published var error: String = "Default error message."
    @Published var personas: [Persona] = []
    @Published var isLoading: Bool = false
    @Published var isEditPersonaViewPresented: Bool = false
    @Published var isAlertPresented = false
    
    func fetchPersonas() {
        print("fetchPersonas()")
        // MARK: Clear array before fetch
        self.personas.removeAll()
        
        self.isLoading = true
        let query = CKQuery(recordType: "Persona", predicate: NSPredicate(value: true))
        privateDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 0) { (result) in
            switch result {
            case .success(let matchResults):
                DispatchQueue.main.async {
                    self.personas.removeAll()
                    matchResults.matchResults.forEach { recordResult in
                        switch recordResult.1 {
                        case .success(let record):
                            
                            DispatchQueue.main.async {
                                
                                guard let title = record["title"] as? String,
                                      let imageAsset = record["image"] as? CKAsset,
                                      let name = record["name"] as? String,
                                      let headline = record["headline"] as? String,
                                      let bio = record["bio"] as? String,
                                      let birthdate = record["birthdate"] as? Date,
                                      let email = record["email"] as? String,
                                      let phone = record["phone"] as? String,
                                      let isFavorite = record["isFavorite"] as? Bool,
                                      let website = record["website"] as? String,
                                      let images = record["images"] as? [CKAsset]
                                else {
                                    print("Some fields are missing or have the wrong type.")
                                    return
                                }
                                
                                // Check if the imageAsset fileURL is not nil
                                guard let fileURL = imageAsset.fileURL else {
                                    print("imageAsset fileURL is missing.")
                                    return
                                }
                                
                                // Load the image from the CKAsset
                                guard let image = UIImage(contentsOfFile: fileURL.path) else {
                                    print("Error loading image from fileURL.")
                                    return
                                }
                                guard let imageAsset = record["image"] as? CKAsset, let _ = imageAsset.fileURL else {
                                    print("'image' field is not of CKAsset type or 'fileURL' property is missing.")
                                    return
                                }
                                let imagesArray = images.compactMap { UIImage(contentsOfFile: $0.fileURL!.path) }
                                
                                let persona = Persona(recordID: record.recordID, title: title, image: image, name: name, headline: headline, bio: bio, birthdate: birthdate, email: email, phone: phone, images: imagesArray, isFavorite: isFavorite, website: website)
                                
                                self.personas.append(persona)
                            }
                            
                        case .failure(let error):
                            DispatchQueue.main.async {
                                self.error = error.localizedDescription
                                self.isAlertPresented = true
                                print(error)
                            }
                        } // end of switch
                    } // end of foreach
                    DispatchQueue.main.async {
                        self.isLoading = false
                        // MARK: pesonas has value
                        for persona in self.personas {
                            print("personas after privateDatabase.fetch(): \(persona.title)")
                        }
                    }
                    print("made it 1")
                } // end of dispatch queue
            case .failure(_):
                print("switch failure in fetchPersonas()")
            } // end of switch
            print("made it 2")
        } // end of fetch
        print("made it 3")
    } // end of func
    
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
                    for persona in self.personas {
                        print("personas after delete: \(persona.title)")
                    }
                }
            }
        }
    }
    
    func updatePersona(images: [UIImage], image: UIImage?, title: String, name: String, headline: String, bio: String, birthdate: Date, email: String, phone: String, recordID: CKRecord.ID, isFavorite: Bool, website: String) {
        self.isLoading = true
//        self.fetchPersonas()
        var imageAssetArray: [CKAsset] = []
        
        for image in images {
            imageAssetArray.append(image.convertToCKAsset()!)
        }
        let imageAsset = image?.convertToCKAsset()
        // Retrieve the existing record from CloudKit
        self.privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isAlertPresented = true
                    print(error)
                }
                return
            }
            guard let record = record else {
                DispatchQueue.main.async {
                    self.error = "Error creating record"
                    self.isAlertPresented = true
                    print("Error creating record")
                }
                return
            }
            
            // Modify the record's properties
            record["images"] = imageAssetArray
            record["image"] = imageAsset
            record["title"] = title
            record["name"] = name
            record["headline"] = headline
            record["bio"] = bio
            record["birthdate"] = birthdate
            record["email"] = email
            record["phone"] = phone
            record["website"] = website
            record["isFavorite"] = isFavorite
            
            self.privateDatabase.save(record) { (savedRecord, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.error = error!.localizedDescription
                        self.isAlertPresented = true
                        print(error as Any)
                    }
                } else {
                    DispatchQueue.main.async {
                        // Update the persona object in the personas array
                        if let index = self.personas.firstIndex(where: { $0.recordID == recordID }) {
                            print("matched")
                            self.personas[index] = Persona(recordID: recordID, title: title, image: image!, name: name, headline: headline, bio: bio, birthdate: birthdate, email: email, phone: phone, images: images, isFavorite: isFavorite, website: website)
                            //                                self.fetchPersonas()
                            for persona in self.personas {
                                print("Personas after update: \(persona.title)" ?? "(empty title)")
                            }
                            // MARK: Why is this empty?
                            if self.personas.isEmpty {
                                print("personas is empty")
                            }
                        } else {
                            print("record not updated")
                            for persona in self.personas {
                                print(persona.recordID)
                            }
                            if self.personas.isEmpty {
                                print("personas is empty")
                            }
                            print("tried to match: \(recordID)")
                        }
                        
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.isLoading = false
            self.isEditPersonaViewPresented = false
        }
    }

    // MARK: create
    func createPersona(record: Persona) {
        self.isLoading = true
        
        DispatchQueue.main.async {
            self.fetchPersonas()
            
            self.privateDatabase.save(record.record) { (savedRecord, error) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        self.error = error!.localizedDescription
                        self.isAlertPresented = true
                        print("Record Not Saved")
                        print(error as Any)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        print("Record Saved")
                        for persona in self.personas {
                            print("personas before privateDatabase.save(): \(persona.title)") // MARK: why is this empty here?
                        }
                        self.personas.append(record)
                        for persona in self.personas {
                            print("personas after privateDatabase.save(): \(persona.title)") // MARK: this only has the recently created record
                        }
                        self.isLoading = false
                    } // end of dispatch queue
                } // end of else
            } // end of fetch
        } // end of dispatch queue
    }
    
    
    private let url = URL(string: "https://thispersondoesnotexist.com/image")!
    
    func fetchImage(completion: @escaping (UIImage?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                // Handle error
                self.error = error?.localizedDescription ?? "An unknown error has occurred"
                self.isAlertPresented = true
                completion(nil,error)
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    completion(image,nil)
                } else {
                    // Handle invalid image data
                    DispatchQueue.main.async {
                        self.error = "Invalid image data"
                        self.isAlertPresented = true
                        completion(nil,nil)
                    }
                }
            }
        }
        task.resume()
    }
}
