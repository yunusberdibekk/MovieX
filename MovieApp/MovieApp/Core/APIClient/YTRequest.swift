//
//  YTRequest.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 6.03.2024.
//

import Foundation

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
