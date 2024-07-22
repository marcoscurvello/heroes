//
//  ImageFetcher.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation
import UIKit

final actor ImageFetcher {
    static let blacklistIdentifiers: Set<String> = [
        "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg",
        "http://i.annihil.us/u/prod/marvel/i/mg/f/60/4c002e0305708.gif"
    ]

    private let cache = NSCache<NSString, UIImage>()
    private var ongoingTasks: [String: Task<UIImage, Error>] = [:]

    func image(for identifier: String) async throws -> UIImage? {
        guard !Self.blacklistIdentifiers.contains(identifier) else {
            throw ImageFetcherError.blacklisted
        }

        if let cachedImage = cache.object(forKey: identifier as NSString) {
            return cachedImage
        }

        if let existingTask = ongoingTasks[identifier] {
            return try await existingTask.value
        }

        guard let url = URL(string: identifier) else {
            throw ImageFetcherError.invalidURL
        }

        let task = Task { () -> UIImage in
            defer { ongoingTasks[identifier] = nil }

            let (data, _) = try await URLSession.shared.data(from: url)

            guard let image = UIImage(data: data) else {
                throw ImageFetcherError.invalidImageData
            }

            cache.setObject(image, forKey: identifier as NSString)
            return image
        }

        ongoingTasks[identifier] = task
        return try await task.value
    }

    func cancelFetch(for identifier: String) {
        ongoingTasks[identifier]?.cancel()
        ongoingTasks[identifier] = nil
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
