//
//  ContentView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 12/22/22.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            // The content for the first tab
            VStack {
                // Your content for the first tab goes here
                ManagePersonasListView()
            }
            .tabItem {
                Image(systemName: "circle.fill")
                Text("Manage Personas")
            }

            // The content for the second tab
            VStack {
                // Your content for the second tab goes here
                PreviewPersonasListView()
            }
            .tabItem {
                Image(systemName: "circle.fill")
                Text("Preview Personas")
            }

            // The content for the third tab
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
