import SwiftUI
import CloudKit



struct EditPersonaView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var persona: Persona
    @State private var showingImagePicker = false
    @State private var showingGalleryImagePicker = false
    
    @State private var sourceType: UIImagePickerController.SourceType? = .photoLibrary
        
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
    
    
    func updatePersona() {
        viewModel.updatePersona(images: self.images, image: self.image, title: self.title, name: self.name, headline: self.headline, bio: self.bio, birthdate: self.birthdate, email: self.email, phone: self.phone, recordID: persona.recordID ?? CKRecord.ID())
    }
    
}

