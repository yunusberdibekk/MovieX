//
//  MAYoutubeSearchResponse.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 29.02.2024.
//

import Foundation

struct MAYoutubeSearchResponse: Codable {
    let items: [VideoElement]
}

struct VideoElement: Codable {
    let id: IdVideoElement
}

struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
