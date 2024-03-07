//
//  MAMovieDetailViewModel.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import Foundation

protocol MAMovieDetailViewModelProtocol {
    // MARK: - Variables

    var view: MAMovieDetailViewControllerProtocol? { get set }
    var movieDetail: MAMovieDetail { get set }
    var movie: Movie { get set }

    // MARK: - Functions

    func viewDidLoad()
    func viewWillAppear()
    func didTapBookmarkButton()
}

final class MAMovieDetailViewModel: MAUserDefaultsManager {
    // MARK: - Variables

    weak var view: MAMovieDetailViewControllerProtocol?
    var movie: Movie
    var movieDetail: MAMovieDetail

    // MARK: - Lifecycle

    init(movie: Movie, movieDetail: MAMovieDetail) {
        self.movie = movie
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

// MARK: -  ViewModel + MAMovieDetailViewModel

extension MAMovieDetailViewModel: MAMovieDetailViewModelProtocol {
    func viewDidLoad() {
        prepareLabels()
        prepareWebView()

        view?.prepareNavigationBar()
        view?.prepareWebView()
        view?.prepareLabels()
    }

    func viewWillAppear() {
        check(movie) { [weak self] result in
            self?.view?.updateBookmarkImage(result ? .bookmark_fill : .bookmark)
        }
    }

    func didTapBookmarkButton() {
        check(movie) { [unowned self] result in
            update(result ? .remove : .add, movie: movie) { [weak self] error in
                self?.view?.alert(
                    title: error == nil ? "Congratulations!" : "Error!",
                    message: error == nil ? "Movie \(result ? "deleted" : "added") successfully" : error?.description ?? "An error occured.",
                    actionTitle: "OK")
                self?.view?.updateBookmarkImage((error == nil && result == false) ? SFSymbols.bookmark_fill : SFSymbols.bookmark)
            }
        }
    }
}
