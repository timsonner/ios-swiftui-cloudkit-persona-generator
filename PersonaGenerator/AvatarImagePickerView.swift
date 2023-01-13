//
//  AvatarImagePickerView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/6/23.
//

import SwiftUI

struct AvatarImagePickerView: View {
    @Binding var image: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var isPresentingImagePicker = false
    @State private var isLoadingImage = false
        var body: some View {
            
                VStack(spacing: 10) {
                    
                    if !isLoadingImage {
                    Image(uiImage: image ?? UIImage(systemName: "person.circle.fill")!)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .scaledToFit()
                        .clipShape(Circle())
                        .padding(.top)
                } else {
                    ProgressView()
                        .frame(width: 200, height: 200)
                }

                Button(action: {
                    self.sourceType = .photoLibrary
                    self.isPresentingImagePicker = true
                }) {
                    Text("Choose from Photo Library")
                }
                Button(action: {
                    self.sourceType = .camera
                    self.isPresentingImagePicker = true
                }) {
                    Text("Take a Photo")
                }

                Button(action: {
                    NetworkManager.shared.fetchImage(from: NetworkManager.url) {
                        (image) in
                        if let image = image {
                            // Update your UI with the image
                            self.image = image
                        } else {
                            // Handle error, for example by showing an alert
                            print("Error fetching image")
                        }
                        self.isLoadingImage = false
                    }
                    self.isLoadingImage = true
                }) {
                    Text("AI Generated Random")
                }
            }
            .sheet(isPresented: $isPresentingImagePicker) {
                ImagePicker(image: self.$image, sourcetype: self.$sourceType)
            }
        }
}


