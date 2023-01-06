//
//  AvatarImagePickerView.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/6/23.
//

import SwiftUI

struct AvatarImagePickerView: View {
    @State private var image: UIImage?
        @State private var sourceType: UIImagePickerController.SourceType?
    @State private var isPresentingImagePicker = false

        var body: some View {
            VStack(spacing: 10) {
                Image(uiImage: image ?? UIImage(systemName: "person.circle.fill")!)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .scaledToFit()
                    .clipShape(Circle())
                    .padding(.top)

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
                    let task = URLSession.shared.dataTask(with: NetworkManager.url) { data, response, error in
                        guard let data = data, error == nil else {
                            // Handle error
                            return
                        }

                        DispatchQueue.main.async {
                            if let image = UIImage(data: data) {
                                // Update image on main thread
                                self.image = image
                            } else {
                                // Handle invalid image data
                            }
                        }
                    }
                    task.resume()
                }) {
                    Text("AI Generated Random")
                }
            }
            .sheet(isPresented: $isPresentingImagePicker) {
                ImagePicker(image: self.$image, sourcetype: self.$sourceType)
            }
        }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImagePickerView()
    }
}



