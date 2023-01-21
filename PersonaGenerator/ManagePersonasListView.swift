//
//  PersonasListView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 12/26/22.
//

import SwiftUI
import CloudKit

struct ManagePersonasListView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var selectedPersona: Persona?
    @State private var searchText = ""
    @State private var isFavorited = false
    var body: some View {
        NavigationView {
            List {
                    if viewModel.isLoading {
                        ProgressView("Loading Personas...")
                    } else {
                        ForEach(viewModel.personas.filter { persona in
                            searchText.isEmpty ? true : persona.title.lowercased().contains(searchText.lowercased())
                        }.filter { persona in
                            isFavorited ? persona.isFavorite : true
                        }) { persona in
                            NavigationLink(destination: PersonaDetailView(persona: persona)) {
                                PersonaRowView(item: persona)
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
                
                .searchable(text: $searchText)
                .toolbar {
                    EditButton()
                }
                .refreshable {
                    viewModel.fetchPersonas()
                }
                .navigationTitle("Manage Personas")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(leading:
                                        HStack {
                    Button(action: {
                        // Present the CreatePersonaView.
                        viewModel.isEditPersonaViewPresented = true
                    }) {
                        Text("Add Persona")
                        Image(systemName: "plus")
                    }
                    Picker("Filter", selection: $isFavorited) {
                        Text("All").tag(false)
                        Text("Favorites").tag(true)
                            
                    }.pickerStyle(SegmentedPickerStyle())
                }
                )
                .sheet(isPresented: $viewModel.isEditPersonaViewPresented) {
                    EditPersonaView(isSheetShowing: $viewModel.isEditPersonaViewPresented, isNew: true)
                }
                .sheet(item: $selectedPersona) { persona in
                    EditPersonaView(isSheetShowing: $viewModel.isEditPersonaViewPresented, persona: persona)
                }
                .task {
                    // Fetch data from CloudKit here
                    print("fetchPersonas from list view")
                    viewModel.fetchPersonas()
                }
            }.alert(isPresented: $viewModel.isAlertPresented) {
                Alert(title: Text("An error has happened..."), message: Text(viewModel.error))
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


