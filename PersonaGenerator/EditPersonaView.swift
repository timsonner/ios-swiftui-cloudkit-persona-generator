import SwiftUI
import CloudKit



struct EditPersonaView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var persona = Persona(recordID: CKRecord.ID(), title: "", image: UIImage(systemName: "person.circle.fill")!, name: "", headline: "", bio: "", birthdate: Date(), email: "", phone: "", images: [])
    
    @State var isNew = false
    @State private var showingImagePicker = false
    @State private var showingGalleryImagePicker = false
    
    @State private var sourceType: UIImagePickerController.SourceType?
        
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
                AvatarImagePickerView()
//                Image(uiImage: image!)
//                    .resizable()
//                    .frame(width: 200, height: 200)
//                    .scaledToFit()
//                    .clipShape(Circle())
//
//                HStack {
//                    Button("Select Image") {
//                        sourceType = .photoLibrary
//                        self.showingImagePicker = true
//                    }
//                    Button("Take Photo") {
//                        sourceType = .camera
//                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                            self.showingImagePicker = true
//                        } else {
//                            print("Camera not available")
//                            // Show an error message or take some other action
//                        }
//                    }
//                    Button("Generate Random") {
//                        NetworkManager.shared.fetchImage(from: NetworkManager.url) { image in
//                                self.image = image
//                            }
//                    }
//                }
                
                }
                    // MARK: TextFields
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
                    
                    // MARK: Gallery View
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
                    
                    
                    if error != nil {
                        Text(error!)
                            .foregroundColor(.red)
                    }
                    // MARK: Button create/update persona
                    Button("Update Persona") {
                        if isNew {
                            createPersona()
                        } else {
                            updatePersona()
                        }
                        print(persona)
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
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: self.$image, sourcetype: self.$sourceType)
            
        }
        .sheet(isPresented: $showingGalleryImagePicker) {
            GalleryImagePicker(images: $images)
        }
        .navigationTitle("Edit Persona")
    }
    
    // MARK: Helper functions
    func updatePersona() {
        viewModel.updatePersona(images: self.images, image: self.image, title: self.title, name: self.name, headline: self.headline, bio: self.bio, birthdate: self.birthdate, email: self.email, phone: self.phone, recordID: persona.recordID!)
    }
    
    func createPersona() {
        for image in images {
            imageAssetArray.append(image.convertToCKAsset()!)
        }
        
        let record = Persona(recordID: CKRecord.ID(), title: title, image: image!, name: name, headline: headline, bio: bio, birthdate: birthdate, email: email, phone: phone, images: imageAssetArray)
        
        viewModel.createPersona(record: record)
    }
}

