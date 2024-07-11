//
//  RequestLoader.swift
//  Heroes
//
//  Created by Marcos Curvello on 05/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import Foundation

class RequestLoader<T: Request> {
    let request: T
    let session: URLSession

    init(request: T, session: URLSession = .shared) {
        self.request = request
        self.session = session
    }

    func load(data: T.RequestDataType, onComplete: @escaping (Result<T.ResponseDataType, RequestLoaderError>) -> Void) {
        do {
            let req = try request.composeRequest(with: data)
            session.dataTask(with: req) { data, response, error in

                if let error = error {
                    onComplete(.failure(.Transport(error)))
                }

                guard let response = response as? HTTPURLResponse else {
                    onComplete(.failure(.Network(error)))
                    return
                }

                let status = response.statusCode
                guard self.expected200to300(status) else {
                    onComplete(.failure(.ServerSide(.init(statusCode: status, response: response))))
                    return
                }

                do {
                    let parsedData = try self.request.parse(data: data)
                    onComplete(.success(parsedData))
                } catch {
                    onComplete(.failure(.Decoding(error)))
                }
            }.resume()
        } catch {
            return onComplete(.failure(.RequestCompose(error)))
        }
    }
}

extension RequestLoader {
    private func expected200to300(_ code: Int) -> Bool {
        return code >= 200 && code < 300
    }
}
