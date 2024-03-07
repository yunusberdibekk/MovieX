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

final class YTRequest: APIRequest {
    private enum Constants {
        static let BASE_URL = "https://youtube.googleapis.com"
        static let API_TOKEN = "AIzaSyDqX8axTGeNpXRiISTGL7Tya7fjKJDYi4g"
    }

    override var baseURL: String {
        Constants.BASE_URL
    }
}

extension YTRequest {
    static func searchRequest(_ query: String) -> YTRequest {
        let queryString = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""

        return .init(
            endpoint: .youtube,
            pathComponents: ["v3/search"],
            queryParameters: [
                .init(name: "q", value: queryString),
                .init(name: "key", value: Constants.API_TOKEN)
            ])
    }
}

final class TMDBRequest: APIRequest {
    private enum Constants {
        static let BASE_URL = "https://api.themoviedb.org/3"
        static let API_TOKEN: String = "    eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3ZmVkZTgxMDA3MjIwZWY2MzcyMzQzNDBhZTY0OWVlYSIsInN1YiI6IjY1Y2I4ZDQ0MTEzODZjMDE3YzUxMTJhYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Xr3LyKawzjig3o4Iw37nckQBur63jgJUJjOhUO8-hzE"
    }

    override var baseURL: String {
        Constants.BASE_URL
    }

    override func urlRequest() -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }

        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer \(Constants.API_TOKEN)"
        ]

        var request = URLRequest(
            url: url,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)

        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers

        return request
    }
}

extension TMDBRequest {
    static let fetchTrendingTvSeries: TMDBRequest = .init(
        endpoint: .trending,
        pathComponents: ["tv/day"])

    static let fetchTrendingMovies: TMDBRequest = .init(
        endpoint: .trending,
        pathComponents: ["movie/day"])

    static let fetchPopularMovies: TMDBRequest = .init(
        endpoint: .movie,
        pathComponents: ["popular"],
        queryParameters: [
            .init(name: "language", value: "en-US"),
            .init(name: "page", value: "1")
        ])

    static let fetchTopRatedMovies: TMDBRequest = .init(
        endpoint: .movie,
        pathComponents: ["top_rated"],
        queryParameters: [
            .init(name: "language", value: "en-US"),
            .init(name: "page", value: "1")
        ])

    static let fetchDiscoverMovies: TMDBRequest = .init(
        endpoint: .movie,
        pathComponents: ["top_rated"],
        queryParameters: [
            .init(name: "language", value: "en-US"),
            .init(name: "sort_by", value: "popularity.desc"),
            .init(name: "include_adult", value: "false"),
            .init(name: "include_video", value: "false"),
            .init(name: "page", value: "1"),
            .init(name: "with_watch_monetization_types", value: "flatrate")
        ])

    static func fetchUpcomingMovies(_ page: String) -> TMDBRequest {
        return .init(
            endpoint: .movie,
            pathComponents: ["upcoming"],
            queryParameters: [
                .init(name: "language", value: "en-US"),
                .init(name: "page", value: page)
            ])
    }
}
