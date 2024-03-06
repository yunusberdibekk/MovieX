//
//  TMDBRequest.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 6.03.2024.
//

import Foundation

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

    static let fetchUpcomingMovies: TMDBRequest = .init(
        endpoint: .movie,
        pathComponents: ["upcoming"],
        queryParameters: [
            .init(name: "language", value: "en-US"),
            .init(name: "page", value: "1")
        ])

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
}
