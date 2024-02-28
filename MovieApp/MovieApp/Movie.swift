//
//  Movie.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import Foundation

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable {
    let id: Int
    let media_type: String?
    let original_name: String?
    let original_title: String?
    let poster_path: String?
    let overview: String?
    let vote_count: Int
    let release_date: String?
    let vote_average: Double
}

extension Movie {
    static let mockMovie: Movie = .init(
        id: 693134,
        media_type: nil,
        original_name: nil,
        original_title: "Dune: Part Two",
        poster_path: "/mFnF8tpPMqEwti2J2aMhYGZYdv0.jpg",
        overview: "Follow the mythic journey of Paul Atreides as he unites with Chani and the Fremen while on a path of revenge against the conspirators who destroyed his family. Facing a choice between the love of his life and the fate of the known universe, Paul endeavors to prevent a terrible future only he can foresee.",
        vote_count: 34,
        release_date: "2024-02-27",
        vote_average: 8.6)
}
