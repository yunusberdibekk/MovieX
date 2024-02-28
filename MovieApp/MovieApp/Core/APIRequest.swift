//
//  APIRequest.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import Foundation

/// Object that represents single API call.
final class APIRequest {
    private enum Constants {
        static let BASE_URL = "https://api.themoviedb.org/3"
        static let API_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3ZmVkZTgxMDA3MjIwZWY2MzcyMzQzNDBhZTY0OWVlYSIsInN1YiI6IjY1Y2I4ZDQ0MTEzODZjMDE3YzUxMTJhYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Xr3LyKawzjig3o4Iw37nckQBur63jgJUJjOhUO8-hzE"
    }

    private let endpoint: APIEndpoint
    private let pathComponents: [String]
    private let queryParameters: [URLQueryItem]

    public let httpMethod = "GET"

    public init(endpoint: APIEndpoint, pathComponents: [String] = [], queryParameters: [URLQueryItem] = []) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
}

extension APIRequest {
    /// It creates urlString according to incoming endpoint, pathComponents and queryParameters.
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

    public var url: URL? {
        URL(string: urlString)
    }

    public var urlRequest: URLRequest? {
        guard let url = url else { return nil }

        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer \(Constants.API_TOKEN)"
        ]

        var request = URLRequest(
            url: url,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)

        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = headers

        return request
    }
}

extension APIRequest {
    static let fetchTrendingTvSeries: APIRequest = .init(
        endpoint: .trending,
        pathComponents: ["tv/day"])

    static let fetchTrendingMovies: APIRequest = .init(
        endpoint: .trending,
        pathComponents: ["movie/day"])

    static let fetchUpcomingMovies: APIRequest = .init(
        endpoint: .movie,
        pathComponents: ["upcoming"],
        queryParameters: [
            .init(name: "language", value: "en-US"),
            .init(name: "page", value: "1")
        ])

    static let fetchPopularMovies: APIRequest = .init(
        endpoint: .movie,
        pathComponents: ["popular"],
        queryParameters: [
            .init(name: "language", value: "en-US"),
            .init(name: "page", value: "1")
        ])

    static let fetchTopRatedMovies: APIRequest = .init(
        endpoint: .movie,
        pathComponents: ["top_rated"],
        queryParameters: [
            .init(name: "language", value: "en-US"),
            .init(name: "page", value: "1")
        ])

    static let fetchDiscoverMovies: APIRequest = .init(
        endpoint: .discover,
        pathComponents: ["movie"],
        queryParameters: [
            .init(name: "language", value: "en-US"),
            .init(name: "sort_by", value: "popularity.desc"),
            .init(name: "include_adult", value: "false"),
            .init(name: "include_video", value: "false"),
            .init(name: "page", value: "1"),
            .init(name: "with_watch_monetization_types", value: "flatrate")
        ])
}
