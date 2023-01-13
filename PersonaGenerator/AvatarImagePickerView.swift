//
//  AvatarImagePickerView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/6/23.
//

import SwiftUI

struct AvatarImagePickerView: View {
    @ObservedObject var viewModel = ViewModel()
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
                NetworkManager.shared.fetchImage(from: NetworkManager.url, viewModel: viewModel) {
                    (image, error) in
                    if let image = image {
                        self.image = image
                    } else {
                        DispatchQueue.main.async {
                            viewModel.error = error?.localizedDescription ?? "Error fetching image"
                            viewModel.isAlertPresented = true
                        }
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
        .alert(isPresented: $viewModel.isAlertPresented) {
            Alert(title: Text("error"), message: Text(viewModel.error))
        }
    }
}


