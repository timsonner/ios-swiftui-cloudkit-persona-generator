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
                            viewModel.deletePersona(persona: persona)
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
