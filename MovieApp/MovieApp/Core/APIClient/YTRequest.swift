//
//  YTRequest.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 29.02.2024.
//

import Foundation

final class YTRequest {
    private enum Constants {
        static let BASE_URL = "https://youtube.googleapis.com"
        static let API_KEY = "AIzaSyDqX8axTGeNpXRiISTGL7Tya7fjKJDYi4g"
    }

    private let endpoint: YTEndpoint
    private let pathComponents: [String]
    private let queryParameters: [URLQueryItem]
    public let httpMethod = "GET"

    public init(endpoint: YTEndpoint, pathComponents: [String] = [], queryParameters: [URLQueryItem] = []) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
}

extension YTRequest {
    private var urlString: String {
        var string = Constants.BASE_URL
        string += "/"
        string += endpoint.rawValue

        if !pathComponents.isEmpty {
            pathComponents.forEach { string += "/\($0)" }
        }

        if !queryParameters.isEmpty {
            string += "?"

            let argumentString = queryParameters.compactMap {
                guard let value = $0.value else { return nil }
                return "\($0.name)=\(value)"
            }.joined(separator: "&")

            string += argumentString
        }

        return string
    }

    var url: URL? {
        URL(string: urlString)
    }
}

extension YTRequest {
    static func searchRequest(_ query: String) -> URLRequest? {
        guard let queryStr = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return nil }
        let ytRquest = YTRequest(
            endpoint: .youtube,
            pathComponents: ["v3/search"],
            queryParameters: [
                .init(name: "q", value: queryStr),
                .init(name: "key", value: Constants.API_KEY)
            ])
        guard let url = ytRquest.url else { return nil }

        return URLRequest(url: url)
    }
}
