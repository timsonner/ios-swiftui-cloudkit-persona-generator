//
//  NetworkSingleton.swift
//  Persona Generator
//
//  Created by Timothy Sonner on 12/21/22.
//

import SwiftUI

class NetworkSingleton {
    func fetchImage() -> Image {
        var image: Image = Image(systemName: "person")
            let url = URL(string: "https://thispersondoesnotexist.com/image")!
                if let data = try? Data(contentsOf: url) {
                    image = Image(uiImage: UIImage(data: data)!)
                    }
        return image
            }
        }

