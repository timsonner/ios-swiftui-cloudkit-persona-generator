//
//  PhotoPicker.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 12/27/22.
//

import SwiftUI

struct PhotoPicker: View {
    @Binding var images: [UIImage]
    @State private var image: UIImage? = UIImage(systemName: "person.circle.fill")
    @State private var showingImagePicker = false
    @State private var showingGalleryImagePicker = false
    @State private var showingInceptionImagePicker = false
    
    @State private var sourceType: UIImagePickerController.SourceType? = .photoLibrary
    
    
    let networkSingleton = NetworkSingleton()
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: self.images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .contextMenu {
                            Button(action: {
                                self.images.remove(at: index)
                            }) {
                                Text("Delete")
                            }
                        }
                }
            }
            
            Button(action: {
                showingImagePicker = true
            }) {
                HStack {
                    Button("Select Image") {
                        showingInceptionImagePicker = true
                    }.sheet(isPresented: $showingInceptionImagePicker) {
                        GalleryImagePicker(images: $images, showPicker: $showingGalleryImagePicker)
                    }
                    
                    Button("Take Photo") {
                        sourceType = .camera
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            self.showingImagePicker = true
                        } else {
                            print("Camera not available")
                            // Show an error message or take some other action
                        }
                    }
                    Button("Generate Random") {
                        images.append( networkSingleton.fetchImage())
                    }
                }
                .sheet(isPresented: $showingGalleryImagePicker) {
                    GalleryImagePicker(images: $images, showPicker: $showingGalleryImagePicker)
                }
            }
        }
    }
}

//struct PhotoPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoPicker()
//    }
//}
