//
//  APIEndpoint.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import Foundation

/// Represents unique API endpoints.
@frozen enum APIEndpoint: String {
    case trending
    case movie
    case discover
    case search
    case original
}
