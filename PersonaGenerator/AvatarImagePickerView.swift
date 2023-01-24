//
//  AvatarImagePickerView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/6/23.
//

import SwiftUI
import PhotosUI

struct AvatarImagePickerView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var image: UIImage?
    @State private var sourceType: 	UIImagePickerController.SourceType?
    @State var selectedImage: [PhotosPickerItem] = []
    @State private var isPresentingImagePicker = false
    @State private var isLoadingImage = false
    
    //MARK: - Body
    var body: some View {
        VStack {
            if !isLoadingImage {
                Image(uiImage: image ?? UIImage(systemName: "person.circle.fill")!)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .scaledToFill()
                    .clipShape(Circle())
                    .padding(.top)
            } else {
                ProgressView()
                    .frame(width: 200, height: 200)
            }
            VStack(spacing: 10) {
                PhotosPicker (
                    selection: $selectedImage,
                    maxSelectionCount: 1,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Choose Photo from Gallery")
                }
                .onChange(of: selectedImage) { items in
                    for item in items {
                        Task {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                image = UIImage(data: data)
                            }
                        }
                    }
                }
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button(action: {
                        self.sourceType = .camera
                        self.isPresentingImagePicker = true
                    }) {
                        Text("Camera")
                    }
                } else {
                    Button {
                        DispatchQueue.main.async {
                            viewModel.error = "Camera not available"
                            viewModel.isAlertPresented = true
                            print("Camera not available...")
                        }
                    }
                label: {
                    Text("Camera")
                }
                .disabled(true)
                }
                
                Button(action: {
                    viewModel.fetchImage() {
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
            .padding()
            .sheet(isPresented: $isPresentingImagePicker) {
                ImagePicker(image: self.$image, sourcetype: self.$sourceType)
            }
            .alert(isPresented: $viewModel.isAlertPresented) {
                Alert(title: Text("error"), message: Text(viewModel.error))
            }
        }.padding()
    }
}


