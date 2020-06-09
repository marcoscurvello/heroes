//
//  ImageFetcher.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

class ImageFetcher {
    
    static let shared = ImageFetcher()
    private let serialAccessQueue = OperationQueue()
    private let fetchQueue = OperationQueue()
    
    private var completionHandlers = [String: [(UIImage?) -> Void]]()
    private var cache = NSCache<NSString, UIImage>()
    
    init() {
        serialAccessQueue.maxConcurrentOperationCount = 1
    }
    
    func cachedImage(for identifier: String) -> UIImage? {
        return cache.object(forKey: identifier as NSString)
    }
    
    func fetchAsync(_ identifier: String, completion: ((UIImage?) -> Void)? = nil) {
        serialAccessQueue.addOperation {
            if let completion = completion {
                let handlers = self.completionHandlers[identifier, default: []]
                self.completionHandlers[identifier] = handlers + [completion]
            }
            
            self.fetchImage(for: identifier)
        }
    }
    
    func cancelFetch(_ identifier: String) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }

            self.operation(for: identifier)?.cancel()
            self.completionHandlers[identifier] = nil
        }
    }
    
    private func fetchImage(for identifier: String) {
         guard operation(for: identifier) == nil else { return }
        
        if let image = cachedImage(for: identifier) {
            invokeCompletionHandlers(for: identifier, with: image)
        } else {
            
            let operation = ImageFetchOperation(identifier: identifier)
            operation.completionBlock = { [weak operation] in
                
                guard let image = operation?.fetchedImage else { return }
                self.cache.setObject(image, forKey: identifier as NSString)
                self.serialAccessQueue.addOperation {
                    self.invokeCompletionHandlers(for: identifier, with: image)
                }
            }
            
            fetchQueue.addOperation(operation)
        }
    }

    private func operation(for identifier: String) -> ImageFetchOperation? {
        for case let fetchOperation as ImageFetchOperation in fetchQueue.operations
            where !fetchOperation.isCancelled && fetchOperation.identifier == identifier {
            return fetchOperation
        }
        
        return nil
    }

    private func invokeCompletionHandlers(for identifier: String, with fetchedData: UIImage) {
        let completionHandlers = self.completionHandlers[identifier, default: []]
        self.completionHandlers[identifier] = nil

        for completionHandler in completionHandlers {
            completionHandler(fetchedData)
        }
    }
    
}
