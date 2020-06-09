//
//  ImageFetchOperation.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class ImageFetchOperation: Operation {
    
    let identifier: String
    private(set) var fetchedImage: UIImage?

    init(identifier: String) {
        self.identifier = identifier
    }

    override func main() {
        
        guard !isCancelled else { return }
        
        guard let url = URL(string: identifier) else {
            return
        }
        
        guard !isCancelled else { return }
        
        guard let imageData = try? Data(contentsOf: url) else {
            return
        }
        
        guard !isCancelled else { return }
        
        fetchedImage = UIImage(data: imageData)
    }
    
    deinit {
        print("\(type(of: self)) deinit")
    }

}