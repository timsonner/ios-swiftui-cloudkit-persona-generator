//
//  PhotoPicker.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/13/23.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    
    @Binding var pickedImage: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        picker.modalPresentationStyle = .overFullScreen
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    class Coordinator: PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let result = results.first {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage, let cgImage = image.cgImage {
                        // Create a CGImageSource from the selected image's CGImage
                        guard let imageSource = CGImageSourceCreateWithData(cgImage.dataProvider!.data! as CFData, nil) else { return }
                        
                        // Create a CGImageDestination for a new image data object
                        guard let imageData = CFDataCreateMutable(nil, 0) else { return }
                        guard let imageDestination = CGImageDestinationCreateWithData(imageData, CGImageSourceGetType(imageSource)!, 1, nil) else { return }
                        
                        // Copy the metadata from the source image to the destination image
                        CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, nil)
                        
                        // Finalize the destination image data
                        if CGImageDestinationFinalize(imageDestination) {
                            // Create a UIImage from the destination image data
                            let exifPreservedImage = UIImage(data: imageData as Data)
                            DispatchQueue.main.async {
                                self.parent.pickedImage = exifPreservedImage
                            }
                        }
                    }
                }
            }
        }

    }
    
}
