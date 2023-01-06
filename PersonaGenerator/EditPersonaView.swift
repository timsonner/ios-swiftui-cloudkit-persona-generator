import SwiftUI
import CloudKit



struct EditPersonaView: View {
    
    @State var persona: Persona
    @State private var showingImagePicker = false
    @State private var showingGalleryImagePicker = false
    
    @State private var sourceType: UIImagePickerController.SourceType? = .photoLibrary
    
//    let networkSingleton = NetworkSingleton()
    
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
    @State private var isUpdating: Bool = false
    @State private var error: String?
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack {
                Image(uiImage: image!)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .scaledToFit()
                    .clipShape(Circle())
                
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
                        self.image = NetworkSingleton.shared.fetchImage()
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: self.$image, sourcetype: self.$sourceType)
                }
                VStack {
                    TextField("Title", text: $title)
                        .textFieldStyle(.roundedBorder)
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Headline", text: $headline)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Bio", text: $bio)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    DatePicker(selection: $birthdate, displayedComponents: .date) {
                        Text("Birthday")
                    }
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Phone", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    VStack {
                        HStack {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(images, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 300, height: 200)
                                            .aspectRatio(contentMode: .fill)
                                            .clipped()
                                    }
                                }
                            }
                        }
                        Button("Edit Gallery") {
                            showingGalleryImagePicker = true
                        }.buttonStyle(.borderedProminent)
                    }
                    .sheet(isPresented: $showingGalleryImagePicker) {
                        PhotoPicker(images: $images)
                    }
                    
                    if error != nil {
                        Text(error!)
                            .foregroundColor(.red)
                    }
                    Button(action: updatePersona) {
                        Text("Update Persona")
                    }.buttonStyle(.borderedProminent)
                        .disabled(isUpdating)
                }
                .padding()
                .onAppear {
                    self.title = self.persona.title
                    self.image = self.persona.image
                    self.name = self.persona.name
                    self.headline = self.persona.headline
                    self.bio = self.persona.bio
                    self.birthdate = self.persona.birthdate
                    self.email = self.persona.email
                    self.phone = self.persona.phone
                    self.images = self.persona.images.compactMap { image in
                        return UIImage(contentsOfFile: image.fileURL!.path)
                    }
                }
            }
        }.navigationTitle("Edit Persona")
    }
    
    
    // MARK: UPDATE PERSONA
    
    func updatePersona() {
        isUpdating = true
        error = nil
        
        for image in images {
            imageAssetArray.append(image.convertToCKAsset()!)
        }
        
        let imageAsset = image?.convertToCKAsset()
        
        // Retrieve the existing record from CloudKit
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let recordID = persona.recordID
        privateDatabase.fetch(withRecordID: recordID!) { (record, error) in
            if let error = error {
                self.error = error.localizedDescription
                self.isUpdating = false
                return
            }
            
            guard let record = record else {
                self.error = "Failed to retrieve record"
                self.isUpdating = false
                return
            }
            
            // Modify the record's properties
            record["images"] = imageAssetArray
            record["image"] = imageAsset
            record["title"] = self.title
            record["name"] = self.name as CKRecordValue
            record["headline"] = self.headline as CKRecordValue
            record["bio"] = self.bio as CKRecordValue
            record["birthdate"] = self.birthdate as CKRecordValue
            record["email"] = self.email as CKRecordValue
            record["phone"] = self.phone as CKRecordValue
            
            privateDatabase.save(record) { (savedRecord, error) in
                self.isUpdating = false
                if let error = error {
                    self.error = error.localizedDescription
                } else {
                    self.persona.recordID = savedRecord?.recordID
                }
            }
        }
    }
    // MARK: //UPDATE PERSONA
}



//struct EditPersonaView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditPersonaView()
//    }
//}

