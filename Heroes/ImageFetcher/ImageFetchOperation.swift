//
//  ImageFetchOperation.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation
import UIKit

final class ImageFetchOperation: Operation {
    let identifier: String
    var fetchedImage: UIImage?
    var error: Error?

    private var task: URLSessionDataTask?
    private let session: URLSession
    private var imageData: Data?

    init(identifier: String, session: URLSession = .shared) {
        self.identifier = identifier
        self.session = session
        super.init()
    }

    override func main() {
        guard !isCancelled else { return }

        guard let url = URL(string: identifier) else {
            error = ImageFetcherError.invalidURL
            return
        }

        let semaphore = DispatchSemaphore(value: 0)

        task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                self.error = error
                semaphore.signal()
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                self.error = ImageFetcherError.invalidResponse(response: response)
                semaphore.signal()
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                self.error = ImageFetcherError.invalidStatus(statusCode: httpResponse.statusCode)
                semaphore.signal()
                return
            }

            guard let data else {
                self.error = ImageFetcherError.invalidData
                semaphore.signal()
                return
            }

            if let image = UIImage(data: data) {
                self.fetchedImage = image
            } else {
                self.error = ImageFetcherError.invalidImageData
            }

            semaphore.signal()
        }

        task?.resume()
        semaphore.wait()
    }

    override func cancel() {
        super.cancel()
        task?.cancel()
    }
}
