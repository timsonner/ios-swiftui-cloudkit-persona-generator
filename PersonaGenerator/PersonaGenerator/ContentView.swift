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
                PersonasListView()
            }
            .tabItem {
                Image(systemName: "circle.fill")
                Text("List")
            }

            // The content for the second tab
            VStack {
                // Your content for the second tab goes here
                Text("This is the content for the second tab (Bar)")
            }
            .tabItem {
                Image(systemName: "circle.fill")
                Text("Bar")
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
