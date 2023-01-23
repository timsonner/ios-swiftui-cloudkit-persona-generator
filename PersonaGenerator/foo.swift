//
//  foo.swift
//  PersonaGenerator
//
//  Created by Timothy Sonner on 1/22/23.
//

import SwiftUI

struct foo: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct foo_Previews: PreviewProvider {
    static var previews: some View {
        foo()
    }
}

//guard let fileURL = imageAsset.fileURL else {
//    print("imageAsset fileURL is missing.")
//    return
//}
//guard let image = UIImage(contentsOfFile: fileURL.path) else {
//    print("Error loading image from fileURL.")
//    return
//}
//let imagesArray = images.compactMap { UIImage(contentsOfFile: $0.fileURL!.path) }
