import SwiftUI
import CloudKit

struct EditPersonaView: View {
    
    //MARK: - View specific properties
    @ObservedObject var viewModel = ViewModel()
    @State var persona = Persona(recordID: CKRecord.ID(), title: "", image: UIImage(systemName: "person.circle.fill")!, name: "", headline: "", bio: "", birthdate: Date(), email: "", phone: "", images: [])
    @State var isNew = false
//    @State private var error: String?
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
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                AvatarImagePickerView(image: self.$image)
                // MARK: TextFields
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.namePhonePad)
                    .textContentType(.name)
                TextField("Headline", text: $headline)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Bio", text: $bio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                DatePicker(selection: $birthdate, displayedComponents: .date) {
                    Text("Birthday")
                }
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                TextField("Phone", text: $phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
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
                    
                    // MARK: Button Create/Update persona
                    Button("Update Persona") {
                        if isNew {
                            createPersona()
                        } else {
                            updatePersona()
                        }
                    }.buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoading)
                    
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                            .progressViewStyle(.circular)
                    }
                }
                .padding()
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
        //        .alert("Loading", isPresented: $viewModel.isLoading, actions: {})
        
    }
    
    
    
    // MARK: Helper functions
    func updatePersona() {
        self.viewModel.updatePersona(images: self.images, image: self.image, title: self.title, name: self.name, headline: self.headline, bio: self.bio, birthdate: self.birthdate, email: self.email, phone: self.phone, recordID: persona.recordID!)
    }
    
    func createPersona() {
        for image in images {
            imageAssetArray.append(image.convertToCKAsset()!)
        }
        
        let record = Persona(recordID: CKRecord.ID(), title: title, image: image!, name: name, headline: headline, bio: bio, birthdate: birthdate, email: email, phone: phone, images: imageAssetArray)
        
        viewModel.createPersona(record: record)
    }
}

