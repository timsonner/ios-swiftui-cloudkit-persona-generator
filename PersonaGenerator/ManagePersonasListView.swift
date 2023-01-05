//
//  PersonasListView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 12/26/22.
//

import SwiftUI
import CloudKit

struct ManagePersonasListView: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.personas) { persona in
                    NavigationLink(destination: EditPersonaView(persona: persona)) {
                        Text(persona.title)
                    }
                    .contextMenu {
                        Button(action: {
                            // Delete the record from CloudKit
                            let privateDatabase = CKContainer.default().privateCloudDatabase
                            privateDatabase.delete(withRecordID: persona.recordID!) { (recordID, error) in
                                if error != nil {
                                    // Handle error
                                } else {
                                    // Remove the deleted record from the `personas` array
                                    viewModel.personas.removeAll(where: { $0.recordID == recordID })
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
            .task {
                // Fetch data from CloudKit here
                viewModel.fetchPersonas()
            }
        }
    }
    
}

struct PersonasListView_Previews: PreviewProvider {
    static var previews: some View {
        ManagePersonasListView()
    }
}
