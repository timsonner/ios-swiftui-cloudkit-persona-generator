//
//  ExtendClasses.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 12/27/22.
//

import Foundation
import SwiftUI
import CloudKit

extension UIImage {
    func convertToCKAsset() -> CKAsset? {
        guard let imageData = self.pngData() else {
            return nil
        }
        let imageFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        do {
            try imageData.write(to: imageFileURL)
            let imageAsset = CKAsset(fileURL: imageFileURL)
            return imageAsset
        } catch {
            return nil
        }
    }
}

