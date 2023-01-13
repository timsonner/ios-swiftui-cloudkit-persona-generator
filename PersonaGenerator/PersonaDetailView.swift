//
//  PersonaDetailView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 12/27/22.
//

import SwiftUI

struct PersonaDetailView: View {
    var persona: Persona
    @State private var isEditPersonaViewPresented = false
    var body: some View {
        Form {
            Section {
                Image(uiImage: persona.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text(persona.name)
                        .font(.title)
                    
                    Text(persona.headline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text("Bio")
                        .font(.headline)
                    
                    Text(persona.bio)
                        .padding()
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text("Contact Information")
                        .font(.headline)
                    
                    HStack {
                        Text("Email:")
                            .font(.subheadline)
                        Spacer()
                        Text(persona.email)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("Phone:")
                            .font(.subheadline)
                        Spacer()
                        Text(persona.phone)
                            .font(.subheadline)
                    }
                }
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Images")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(persona.images, id: \.self) { image in
                                Image(uiImage: UIImage(contentsOfFile: image.fileURL!.path)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 200)
                                    .clipped()
                            }
                        }
                    }
                }
            }
        }
        .navigationBarItems(trailing: Button(action: {
            // Navigate to the EditPersonaView
            isEditPersonaViewPresented = true
        }) {
            Text("Edit")
        })
        .sheet(isPresented: $isEditPersonaViewPresented) {
            EditPersonaView(isSheetShowing: $isEditPersonaViewPresented, persona: persona)
        }
    }
}


//struct PersonaDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonaDetailView()
//    }
//}
