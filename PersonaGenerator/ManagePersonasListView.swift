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
    @State private var searchText: String = ""
    @State private var isFavorited: Bool = false
    @State private var isFirstLoad: Bool = true
    @State private var isEditPersonaViewPresented = false
    
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
                        viewModel.isCreatePersonaViewPresented = true
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
                .sheet(isPresented: $viewModel.isCreatePersonaViewPresented) {
                    EditPersonaView(isSheetShowing: $viewModel.isCreatePersonaViewPresented, isNew: true)
                }
//                .sheet(item: $selectedPersona) { persona in
//                    EditPersonaView(isSheetShowing: $isEditPersonaViewPresented, persona: persona)
//                }
                .task {
                    if isFirstLoad {
                        print("fetchPersonas() called from list view")
                        viewModel.fetchPersonas()
                        isFirstLoad = false
                    }
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


