//
//  PersonaListRowView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/4/23.
//

import SwiftUI

struct PersonaListRowView: View {
    var item: Persona
    var body: some View {
        NavigationLink(destination: PersonaDetailView(persona: item)) {
            HStack {
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 60, alignment: .center)
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
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//struct PersonaListRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonaListRowView()
//    }
//}
