//
//  MXMovieDetailViewModel.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import Foundation

protocol MXMovieDetailViewModelProtocol {
    var view: MXMovieDetailViewControllerProtocol? { get set }
    var movieDetail: MovieDetail { get set }
    var movie: Movie { get set }

    func viewDidLoad()
    func viewWillAppear()
    func didTapBookmarkButton()
}

final class MXMovieDetailViewModel: MXUserDefaultsManager {
    weak var view: MXMovieDetailViewControllerProtocol?
    var movie: Movie
    var movieDetail: MovieDetail

    // MARK: - Lifecycle

    init(movie: Movie, movieDetail: MovieDetail) {
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

extension MXMovieDetailViewModel: MXMovieDetailViewModelProtocol {
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
