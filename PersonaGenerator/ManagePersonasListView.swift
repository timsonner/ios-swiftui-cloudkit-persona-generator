//
//  PersonasListView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 12/26/22.
//

import SwiftUI
import CloudKit

struct ManagePersonasListView: View {
    @State private var personas: [Persona] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(personas) { persona in
                    NavigationLink(destination: EditPersonaView(persona: persona)) {
                        Text(persona.title)
                    }
                    .contextMenu {
                        Button(action: {
                            // Delete the record from CloudKit
                            let privateDatabase = CKContainer.default().privateCloudDatabase
                            privateDatabase.delete(withRecordID: persona.recordID!) { (recordID, error) in
                                if let error = error {
                                    // Handle error
                                } else {
                                    // Remove the deleted record from the `personas` array
                                    self.personas.removeAll(where: { $0.recordID == recordID })
                                }
                            }
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Manage Personas")
            .onAppear {
                // Fetch data from CloudKit here
                let privateDatabase = CKContainer.default().privateCloudDatabase
                let query = CKQuery(recordType: "Persona", predicate: NSPredicate(value: true))
                privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
                    if let error = error {
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



struct PersonasListView_Previews: PreviewProvider {
    static var previews: some View {
        ManagePersonasListView()
    }
}
