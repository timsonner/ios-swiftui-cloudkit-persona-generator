//
//  PersonaListRowView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/4/23.
//

import SwiftUI

struct PersonaRowView: View {

    @State var isItemFavorited: Bool = false
    var item: Persona
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            Image(uiImage: item.image)
                .resizable()
                .frame(width: 80, height: 60, alignment: .center)
                .scaledToFill()
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.title)
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(item.headline)
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
                viewModel.updatePersona(images: item.images, image: item.image, title: item.title, name: item.name, headline: item.headline, bio: item.bio, birthdate: item.birthdate, email: item.email, phone: item.phone, recordID: item.recordID!, isFavorite: isItemFavorited, website: item.website)
            }
            .frame(width: 40, height: 40)
        }
        .onAppear {
            self.isItemFavorited = self.item.isFavorite
        }
    }
}
