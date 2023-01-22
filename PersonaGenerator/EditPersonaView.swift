//
//  EditPersonaView.swift
//  Persona Generator
//
//  Created by Timothy Sonner on 12/21/22.
//

import SwiftUI
import CloudKit
import _PhotosUI_SwiftUI

// text input  auto cpitalization .word

struct EditPersonaView: View {
    //MARK: - View specific properties
    @ObservedObject var viewModel = ViewModel()
    @Binding var isSheetShowing: Bool // Bool to dismiss sheet
    @State var selectedImage: [PhotosPickerItem] = []
    
    
    @State var persona = Persona(recordID: CKRecord.ID(), title: "", image: UIImage(systemName: "person.circle.fill")!, name: "", headline: "", bio: "", birthdate: Date(), email: "", phone: "", images: [], isFavorite: false, website: "")
    
    @State var isNew = false
    @State private var showingImagePicker = false
    @State private var showingGalleryImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType?
    
    //MARK: - Persona specific properties
    @State private var image: UIImage? = UIImage(systemName: "person.circle.fill")
    @State private var imageAssetArray: [CKAsset] = []
    @State private var title: String = ""
    @State private var name: String = ""
    @State private var headline: String = ""
    @State private var bio: String = ""
    @State private var birthdate: Date = Date()
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var images: [UIImage] = []
    @State private var isFavorite: Bool = false
    @State private var website: String = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                AvatarImagePickerView(image: self.$image)
                // MARK: TextFields
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                //                    .keyboardType(.namePhonePad)
                    .textInputAutocapitalization(.words)
                TextField("Headline", text: $headline)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Bio", text: $bio, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(40)
                DatePicker(selection: $birthdate, displayedComponents: .date) {
                    Text("Birthday")
                }
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                TextField("Website", text: $website)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.webSearch)
                TextField("Phone", text: $phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
                // MARK: Gallery View
                VStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(images, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 300, height: 200)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .contextMenu {
                                        Button(action: {
                                            self.images.remove(at: self.images.firstIndex(of: image)!)
                                        }) {
                                            Text("Delete")
                                            Image(systemName: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    VStack {
                        PhotosPicker (
                            selection: $selectedImage,
                            maxSelectionCount: 5,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Text("Choose Photos from Gallery")
                        }
                        .onChange(of: selectedImage) { items in
                            for item in items {
                                Task {
                                    if let data = try? await item.loadTransferable(type: Data.self) {
                                        images.append(((UIImage(data: data) ?? UIImage(systemName: "person"))!))
                                    }
                                }
                            }
                        }
                        
                        // MARK: Button Create/Update persona
                        Button("Save") {
                            if isNew {
                                createPersona()
                                isSheetShowing = false
                            } else {
                                updatePersona()
                                    isSheetShowing = false
                            }
                        }.buttonStyle(.borderedProminent)
                            .disabled(viewModel.isLoading)
                            .tint(.green)
                        if viewModel.isLoading {
                            ProgressView("Saving...")
                                .progressViewStyle(.circular)
                        }
                    }
                }// Main Vstack
                .onAppear {
                    self.title = self.persona.title
                    self.image = self.persona.image
                    self.name = self.persona.name
                    self.headline = self.persona.headline
                    self.bio = self.persona.bio
                    self.birthdate = self.persona.birthdate
                    self.email = self.persona.email
                    self.phone = self.persona.phone
                    self.images = self.persona.images
                }
            }
            .padding(.horizontal)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: self.$image, sourcetype: self.$sourceType)
            }
            .sheet(isPresented: $showingGalleryImagePicker) {
                GalleryImagePicker(images: $images)
            }
            .navigationTitle("Edit Persona")
            .alert(isPresented: $viewModel.isAlertPresented) {
                Alert(title: Text("Error"), message: Text(self.viewModel.error))
            }
        } // scroll view
    }
    
    
    // MARK: Helper functions
    func updatePersona() {
        self.viewModel.updatePersona(images: self.images, image: self.image, title: self.title, name: self.name, headline: self.headline, bio: self.bio, birthdate: self.birthdate, email: self.email, phone: self.phone, recordID: persona.recordID!, isFavorite: self.isFavorite, website: self.website)
        
        if let index = viewModel.personas.firstIndex(where: { $0.recordID == persona.recordID }) {
            print("matched")
            // MARK: Update - trying to trigger refresh of ui
            viewModel.personas[index] = Persona(recordID: persona.recordID, title: persona.title, image: persona.image, name: persona.name, headline: persona.headline, bio: persona.bio, birthdate: persona.birthdate, email: persona.email, phone: persona.phone, images: persona.images, isFavorite: persona.isFavorite, website: persona.website)
            //                                self.fetchPersonas()
            for persona in viewModel.personas {
                print(persona.recordID ?? "no-ID")
            }
            if viewModel.personas.isEmpty {
                print("personas is empty")
            }
        }
    }
    
    func createPersona() {
        for image in images {
            imageAssetArray.append(image.convertToCKAsset()!)
        }
        
        // MARK: Create - trying to trigger refresh of ui
        viewModel.personas.append(Persona(recordID: persona.recordID, title: title, image: image!, name: name, headline: headline, bio: bio, birthdate: birthdate, email: email, phone: phone, images: images, isFavorite: isFavorite, website: website))
        
        viewModel.createPersona(record: Persona(recordID: persona.recordID, title: title, image: image!, name: name, headline: headline, bio: bio, birthdate: birthdate, email: email, phone: phone, images: images, isFavorite: isFavorite, website: website))
    }
}



