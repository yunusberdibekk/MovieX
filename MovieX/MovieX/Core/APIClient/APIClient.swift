//
//  APIClient.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import Foundation

protocol APIClientProtocol {
    var session: URLSession { get }

    func execute<T: Codable>(_ request: URLRequest?,
                             expecting type: T.Type, completion: @escaping (Result<T, APIClientError>) -> Void)
}

final class APIClient {
    static let shared: APIClient = .init()

    private init() {}
}

extension APIClient: APIClientProtocol {
    var session: URLSession {
        URLSession.shared
    }

    func execute<T: Codable>(_ request: URLRequest?,
                             expecting type: T.Type, completion: @escaping (Result<T, APIClientError>) -> Void)
    {
        guard let request else {
            completion(.failure(.invalidRequest(msg: "Invalid Request!")))
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
            guard let data, error == nil else {
                completion(.failure(.invalidRequest(msg: error?.localizedDescription ?? "")))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse(msg: response?.description ?? "")))
                return
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidStatusCode(code: httpResponse.statusCode.description)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode(type.self, from: data)

                completion(.success(results))
            } catch {
                completion(.failure(.invalidDecoding(msg: error.localizedDescription)))
            }
        }

        task.resume()
    }
}

enum APIClientError: Error {
    case invalidRequest(msg: String)
    case invalidResponse(msg: String)
    case invalidStatusCode(code: String)
    case invalidDecoding(msg: String)

    var description: String {
        switch self {
        case .invalidRequest(let msg):
            "@MXClient: Network Request Error: \(msg)"
        case .invalidResponse(let msg):
            "@MXClient: Invalid Response or No HTTP Response Error: \(msg)"
        case .invalidStatusCode(let code):
            "@MXClient: Invalid HTTP Status Code: \(code)"
        case .invalidDecoding(let msg):
            "@MXClient: JSON Decoding Error: \(msg)"
        }
    }
}
