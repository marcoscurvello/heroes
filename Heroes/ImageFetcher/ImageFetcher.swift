//
//  ImageFetcher.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation
import UIKit

final class ImageFetcher {

    fileprivate let blacklistIdentifiers: [String] = [
        "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg",
        "http://i.annihil.us/u/prod/marvel/i/mg/f/60/4c002e0305708.gif"
    ]

    private let serialAccessQueue = DispatchQueue(label: "com.imagefetcher.serialAccess")
    private let fetchQueue = OperationQueue()

    private let completionHandlers = NSMapTable<NSString, NSMutableArray>.strongToStrongObjects()
    private var cache = NSCache<NSString, UIImage>()

    func image(for identifier: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        serialAccessQueue.async { [weak self] in
            guard let self else { return }

            guard !self.blacklistIdentifiers.contains(identifier) else {
                completion(.failure(ImageFetcherError.blacklisted))
                return
            }

            let handlers = self.completionHandlers.object(forKey: identifier as NSString) ?? NSMutableArray()
            handlers.add(completion)
            self.completionHandlers.setObject(handlers, forKey: identifier as NSString)
            self.fetchData(for: identifier)
        }
    }

    func cachedImage(for identifier: String) -> UIImage? {
        cache.object(forKey: identifier as NSString)
    }

    func cancelFetch(_ identifier: String) {
        serialAccessQueue.async { [weak self] in
            guard let self else { return }

            self.fetchQueue.operations.forEach { operation in
                if let imageOperation = operation as? ImageFetchOperation,
                   imageOperation.identifier == identifier {
                    imageOperation.cancel()
                }
            }

            self.completionHandlers.removeObject(forKey: identifier as NSString)
        }
    }

    private func fetchData(for identifier: String) {
        if let image = cachedImage(for: identifier) {
            invokeCompletionHandlers(for: identifier, with: .success(image))
        } else if !isOperationInProgress(for: identifier) {

            let operation = ImageFetchOperation(identifier: identifier)
            operation.completionBlock = { [weak self, weak operation] in
                guard let self, let operation, !operation.isCancelled else { return }

                if let image = operation.fetchedImage {
                    self.cache.setObject(image, forKey: identifier as NSString)
                    self.invokeCompletionHandlers(for: identifier, with: .success(image))
                } else if let error = operation.error {
                    self.invokeCompletionHandlers(for: identifier, with: .failure(error))
                }
            }
            fetchQueue.addOperation(operation)
        }
    }

    private func isOperationInProgress(for identifier: String) -> Bool {
        fetchQueue.operations.contains { operation in
            guard let imageOperation = operation as? ImageFetchOperation else { return false }
            return !imageOperation.isCancelled && imageOperation.identifier == identifier
        }
    }

    private func invokeCompletionHandlers(for identifier: String, with result: Result<UIImage, Error>) {
        serialAccessQueue.async { [weak self] in
            guard let self else { return }
            guard let handlers = self.completionHandlers.object(forKey: identifier as NSString) as? [((Result<UIImage, Error>) -> Void)] else { return }
            self.completionHandlers.removeObject(forKey: identifier as NSString)
            DispatchQueue.main.async {
                handlers.forEach { $0(result) }
            }
        }
    }
}
