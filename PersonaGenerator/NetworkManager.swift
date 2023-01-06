//
//  NetworkSingleton.swift
//  Persona Generator
//
//  Created by Timothy Sonner on 12/21/22.
//

import SwiftUI

class NetworkManager {
    
    static var shared = NetworkManager()
    static let url = URL(string: "https://thispersondoesnotexist.com/image")!
    
    private init() {}
    
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                // Handle error
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    // Handle invalid image data
                    completion(nil)
                }
            }
        }
        task.resume()
    }
}
