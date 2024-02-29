//
//  MovieDetailViewModel.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import Foundation

protocol MovieDetailViewModelProtocol {
    var view: MovieDetailViewControllerProtocol? { get set }
    var movieDetail: MovieDetail { get set }

    func viewDidLoad()
    func viewWillAppear()
}

final class MovieDetailViewModel {
    weak var view: MovieDetailViewControllerProtocol?
    var movieDetail: MovieDetail

    init(movieDetail: MovieDetail) {
        self.movieDetail = movieDetail
    }

    private func prepareLabels() {
        view?.titleLabel.text = movieDetail.title
        view?.overviewLabel.text = movieDetail.overview
    }

    private func prepareWebView() {
        guard let youtubeVideo = movieDetail.youtubeVideo,
              let url = URL(string: "https://www.youtube.com/embed/\(youtubeVideo.id.videoId)")
        else {
            return
        }

        view?.webView.load(URLRequest(url: url))
    }
}

extension MovieDetailViewModel: MovieDetailViewModelProtocol {
    func viewDidLoad() {
        prepareLabels()
        prepareWebView()

        view?.prepareNavigationBar()
        view?.prepareWebView()
        view?.prepareLabels()
    }

    func viewWillAppear() {}
}
