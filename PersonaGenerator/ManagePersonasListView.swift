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
//    @State private var isCreatePersonaViewPresented = false
    @State private var selectedPersona: Persona?
    var body: some View {
        
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading Personas...")
                } else {
                    ForEach(viewModel.personas) { persona in
                        
                        NavigationLink(destination: PersonaDetailView(persona: persona)) {
                            
                            PersonaListRowView(item: persona)
                                .contextMenu {
                                    Button(action: {
                                        selectedPersona = persona
                                    }) {
                                        Text("Edit")
                                        Image(systemName: "pencil")
                                    }
                                } // .contextMenu
                        }
                    } // End ForEach
                    .onDelete(perform: deletePersona)
                }
            }
            .toolbar {
                EditButton()
            }
            .refreshable {
                viewModel.fetchPersonas()
            }
            .navigationTitle("Manage Personas")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(leading: Button(action: {
                // Present the CreatePersonaView.
                viewModel.isCreatePersonaViewPresented = true
            }) {
                Text("Add Persona")
                Image(systemName: "plus")
            })
            .sheet(isPresented: $viewModel.isCreatePersonaViewPresented) {
                EditPersonaView(isNew: true)
            }
            .sheet(item: $selectedPersona) { persona in
                EditPersonaView(persona: persona)
            }
            .task {
                // Fetch data from CloudKit here
                viewModel.fetchPersonas()
            }
        }
    }
    
    // MARK: Helpers
    func deletePersona(offsets: IndexSet) {
        withAnimation {
            // Get the index of the persona to delete.
            let index = offsets.first!
            // Get the persona to delete.
            let persona = viewModel.personas[index]
            // Delete the persona from CloudKit.
            DispatchQueue.main.async {
                viewModel.deletePersona(persona: persona)
            }
        }
    }
}

struct PersonasListView_Previews: PreviewProvider {
    static var previews: some View {
        ManagePersonasListView()
    }
}
