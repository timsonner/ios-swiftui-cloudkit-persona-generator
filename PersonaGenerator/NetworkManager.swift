//
//  NetworkSingleton.swift
//  Persona Generator
//
//  Created by Timothy Sonner on 12/21/22.
//

import SwiftUI

class NetworkManager {
    
    static var shared = NetworkManager()
    static let url = URL(string: "https://thispersondoesnotexist.com/imagezz")!
    
//    private init() {}
    
    func fetchImage(from url: URL, viewModel: ViewModel, completion: @escaping (UIImage?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                // Handle error
                viewModel.error = error?.localizedDescription ?? "An unknown error has occurred"
                viewModel.isAlertPresented = true
                completion(nil,error)
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    completion(image,nil)
                } else {
                    // Handle invalid image data
                    viewModel.error = "Invalid image data"
                    viewModel.isAlertPresented = true
                    completion(nil,nil)
                }
            }
        }
        task.resume()
    }
}
