//
//  PersonaListRowView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/4/23.
//

import SwiftUI

struct PersonaRowView: View {

    @State var isItemFavorited: Bool = false
    var persona: Persona
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            Image(uiImage: persona.image)
                .resizable()
                .frame(width: 80, height: 60, alignment: .center)
                .scaledToFill()
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text(persona.title)
                    .font(.title)
                Text(persona.name)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(persona.headline)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: {
            }) {
                Image(systemName: self.isItemFavorited ? "star.fill" : "star").foregroundColor(.yellow)
                    .rotationEffect(.degrees(isItemFavorited ? 360 : 0))
                    .animation(.easeIn(duration: 0.5), value: isItemFavorited)
            }.onTapGesture {
                isItemFavorited.toggle()
                    updatePersona()
            }
            .frame(width: 40, height: 40)
        }
        .task {
            self.isItemFavorited = self.persona.isFavorite
            
            if self.viewModel.personas.isEmpty {
                self.viewModel.fetchPersonas()
            }
        }
    }
    
    func updatePersona() {
        viewModel.updatePersona(images: persona.images, image: persona.image, title: persona.title, name: persona.name, headline: persona.headline, bio: persona.bio, birthdate: persona.birthdate, email: persona.email, phone: persona.phone, recordID: persona.recordID!, isFavorite: isItemFavorited, website: persona.website)
        
        if viewModel.personas.isEmpty {
            print("empty personas array in updatePersona helper on edit view.")
        }
        // MARK: Update the UI here...
        if let index = viewModel.personas.firstIndex(where: { $0.recordID == persona.recordID }) {
            print("Update happened on \(viewModel.personas[index].title)")
            viewModel.personas[index] = Persona(recordID: persona.recordID, title: persona.title, image: persona.image, name: persona.name, headline: persona.headline, bio: persona.bio, birthdate: persona.birthdate, email: persona.email, phone: persona.phone, images: persona.images, isFavorite: isItemFavorited, website: persona.website)
            for persona in viewModel.personas {
                print("Personas in viewmodel after update: \(persona.title)")
            }
        } else {
            print("record not updated")
            for persona in viewModel.personas {
                print(persona.recordID ?? "no record id")
            }
            if viewModel.personas.isEmpty {
                print("personas is empty")
            }
            print("tried to match: \(String(describing: persona.recordID))")
        }
    }
    
}
