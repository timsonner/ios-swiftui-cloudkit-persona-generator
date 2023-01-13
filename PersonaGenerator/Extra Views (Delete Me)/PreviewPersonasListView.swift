//
//  PreviewPersonasView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 12/27/22.
//

import SwiftUI
import CloudKit

struct PreviewPersonasListView: View {
    @State private var personas: [Persona] = []
    
    var body: some View {
        NavigationView {
            List(personas) { persona in
                NavigationLink(destination: PersonaDetailView(persona: persona)) {
                    Text(persona.title)
                }
            }
            .navigationTitle("Preview Personas")
            .onAppear {
                // Fetch data from CloudKit here
                let privateDatabase = CKContainer.default().privateCloudDatabase
                let query = CKQuery(recordType: "Persona", predicate: NSPredicate(value: true))
                
                privateDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 0) { (result) in
                    switch result {
                    case .success(let matchResults):
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
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}
