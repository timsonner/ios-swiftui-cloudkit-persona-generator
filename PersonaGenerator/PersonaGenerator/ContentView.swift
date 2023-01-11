//
//  ContentView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 12/22/22.
//

import SwiftUI

struct ContentView: View {
    //    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        TabView {
            // First tab.
            VStack {
                ManagePersonasListView()
            }
            .tabItem {
                Image(systemName: "circle.fill")
                Text("Manage Personas")
            }
            
            // Second tab.
            VStack {
                PreviewPersonasListView()           }
            .tabItem {
                Image(systemName: "circle.fill")
                Text("Preview Personas")
            }
            
            // Third tab.
            VStack {
                CreatePersonaView()
            }
            .tabItem {
                Image(systemName: "circle.fill")
                Text("Create Persona")
            }
        }
    }
}
