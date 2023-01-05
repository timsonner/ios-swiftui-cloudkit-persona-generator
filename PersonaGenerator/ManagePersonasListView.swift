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
    
    @State private var isCreatePersonaViewPresented = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.personas) { persona in
                    NavigationLink(destination: EditPersonaView(persona: persona)) {
                        PersonaListRowView(item: persona)
                    }
                    .contextMenu {
                        Button(action: {
                            // Delete the record from CloudKit
                            DispatchQueue.main.async {
                                viewModel.deletePersona(persona: persona)
                            }
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                    }
                }
                .onDelete(perform: deletePersona)
            }
            .toolbar {
                EditButton()
            }
            .navigationTitle("Manage Personas")
            .navigationBarItems(leading: Button(action: {
                // Set the `isCreatePersonaViewPresented` state to true to present the `CreatePersonaView`
                isCreatePersonaViewPresented = true
            }) {
                Text("Add Persona")
                Image(systemName: "plus")
            })
            .sheet(isPresented: $isCreatePersonaViewPresented) {
                CreatePersonaView()
            }
            .task {
                // Fetch data from CloudKit here
                viewModel.fetchPersonas()
            }
        }
    }
    
    func deletePersona(offsets: IndexSet) {
        withAnimation {
            // Delete the persona from the `personas` array
            viewModel.personas.remove(atOffsets: offsets)

            // Get the index of the persona to delete
            let index = offsets.first!

            // Get the persona to delete
            let persona = viewModel.personas[index]

            // Delete the persona from CloudKit
            viewModel.deletePersona(persona: persona)
        }
    }
}


struct PersonasListView_Previews: PreviewProvider {
    static var previews: some View {
        ManagePersonasListView()
    }
}
