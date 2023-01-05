//
//  NetworkSingleton.swift
//  Persona Generator
//
//  Created by Timothy Sonner on 12/21/22.
//

import SwiftUI

class NetworkSingleton {
    
    static var shared = NetworkSingleton()
    
    func fetchImage() -> UIImage {
        
        var image: UIImage = UIImage(systemName: "person")!
            let url = URL(string: "https://thispersondoesnotexist.com/image")!
                if let data = try? Data(contentsOf: url) {
                    image = UIImage(data: data)!
                    }
        return image
            }
    
        }
