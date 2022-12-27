import SwiftUI
import CloudKit

struct EditPersonaView: View {
    @State var persona: Persona
//    @State private var image: UIImage
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
                Image(uiImage: persona.image)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .scaledToFit()
                    .clipShape(Circle())
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
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                        }
                    }
                }
                if error != nil {
                    Text(error!)
                        .foregroundColor(.red)
                }
                Button(action: updatePersona) {
                    Text("Update Persona")
                }
                .disabled(isUpdating)
            }
            .padding()
            .onAppear {
//                self.image = self.persona.image
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
    }
    // MARK: UPDATE PERSONA
    
    func updatePersona() {
        isUpdating = true
        error = nil
        
        // Update the persona object
//        persona.image = image
        persona.name = name
        persona.headline = headline
        persona.bio = bio
        persona.birthdate = birthdate
        persona.email = email
        persona.phone = phone
        persona.images = images.map { image in
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("image.png")
            if let imageData = image.pngData() {
                try? imageData.write(to: fileURL)
            }
            return CKAsset(fileURL: fileURL)
        }

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
            record["name"] = self.name as CKRecordValue
            record["headline"] = self.headline as CKRecordValue
            record["bio"] = self.bio as CKRecordValue
            record["birthdate"] = self.birthdate as CKRecordValue
            record["email"] = self.email as CKRecordValue
            record["phone"] = self.phone as CKRecordValue
            record["images"] = self.images.map { image in
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("image.png")
                if let imageData = image.pngData() {
                    try? imageData.write(to: fileURL)
                }
                return CKAsset(fileURL: fileURL)
            } as CKRecordValue

            // Save the modified record to CloudKit
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

