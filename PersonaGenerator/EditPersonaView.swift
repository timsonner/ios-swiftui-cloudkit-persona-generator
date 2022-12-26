//
//  EditPersonaView.swift
//  Persona Generator
//
//  Created by Timothy Sonner on 12/21/22.
//

import SwiftUI
import CloudKit

struct EditPersonaView: View {
    
    // User avatar variables
    @State private var image: UIImage? = UIImage(systemName: "person.circle.fill")
    
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType? = .photoLibrary
    let networkSingleton = NetworkSingleton()
    
    // User data variables

    @State private var name: String = ""
    @State private var headline: String = ""
    @State private var bio: String = ""
    @State private var birthdate: Date = Date()
    @State private var email: String = ""
    @State private var phone: String = ""
    
    // declare database
    let database = CKContainer.default().privateCloudDatabase
    
    var body: some View {
        VStack {
            VStack {
                Image(uiImage: image!)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .scaledToFit()
                    .clipShape(Circle())
                    .foregroundColor(.gray)
                HStack {
                    Button("Select Image") {
                        sourceType = .photoLibrary
                        self.showingImagePicker = true
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
                        image = networkSingleton.fetchImage()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: self.$image, sourcetype: self.$sourceType)
            }
            
            TextField("Name", text: $name)
                .padding()
            TextField("Headline", text: $headline)
                .padding()
            TextField("Bio", text: $bio)
                .padding()
                .multilineTextAlignment(.leading)
            DatePicker(selection: $birthdate, displayedComponents: .date) {
                Text("Birthdate")
            }
            .padding()
            TextField("Email", text: $email)
                .padding()
            TextField("Phone", text: $phone)
                .padding()
            Spacer()
            Button("Save") {

                let record = Persona(image: image!, name: name, headline: headline, bio: bio, birthdate: birthdate, email: email, phone: phone)

                database.save(record.record) { (savedRecord, error) in
                           if error == nil {
                               print("Record Saved")
                               
                           } else {
                               print("Record Not Saved")
                               print(error)
                           }
                       }
            }
        } // Some View
    } // Body
}  // Struct


struct EditPersonaView_Previews: PreviewProvider {
    static var previews: some View {
        EditPersonaView()
    }
}

