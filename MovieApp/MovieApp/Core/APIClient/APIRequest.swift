//
//  APIRequest.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

class APIRequest {
    var endpoint: APIEndpoint
    var httpMethod: HTTPMethod
    var pathComponents: [String]
    var queryParameters: [URLQueryItem]
    var headers: [String: String]

    var baseURL: String {
        ""
    }

    init(endpoint: APIEndpoint, httpMethod: HTTPMethod = .get, pathComponents: [String],
         queryParameters: [URLQueryItem] = [], headers: [String: String] = [:])
    {
        self.endpoint = endpoint
        self.httpMethod = httpMethod
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
        self.headers = headers
    }

    var urlString: String {
        var urlString = baseURL.appending("/" + endpoint.rawValue)

        for path in pathComponents {
            urlString.append("/" + path)
        }

        if !queryParameters.isEmpty {
            urlString.append("?")

            let argumentString = queryParameters.compactMap {
                guard let value = $0.value else { return nil }
                return "\($0.name)=\(value)"
            }
            .joined(separator: "&")

            urlString.append(argumentString)
        }

        return urlString
    }

    func urlRequest() -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)

        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers

        return request
    }
}
