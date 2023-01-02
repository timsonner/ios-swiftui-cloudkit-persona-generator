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
                
                privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
                    if error != nil {
                        // Handle error
                    } else {
                        self.personas = records!.compactMap { record in
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
                        }
                        
                    }
                }
            }
        }
    }
}


struct PreviewPersonasListView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewPersonasListView()
    }
}
