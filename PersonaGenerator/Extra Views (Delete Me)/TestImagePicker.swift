//
//  TestImagePicker.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/6/23.
//

import SwiftUI
import PhotosUI

struct TestImagePicker: View {
    
    //MARK: - Properties
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var imageData: [PhotosPickerItem: Data] = [:]
    
    //MARK: - Body
    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 2,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Choose Photos from Gallery")
            }
            .onChange(of: selectedItems) { newValue in
                for item in newValue {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            imageData[item] = data
                        }
                    }
                }
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Array(imageData.keys), id: \.self) { item in
                        if let data = imageData[item], let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
