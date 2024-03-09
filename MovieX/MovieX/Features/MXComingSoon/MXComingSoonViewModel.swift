//
//  MXComingSoonViewModel.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 7.03.2024.
//

import Foundation

protocol MXComingSoonViewModelProtocol {
    var view: MXComingSoonViewControllerProtocol? { get set }

    func viewDidLoad()
    func viewWillAppear()
    func didSelectItemAt(_ index: Int)
    func sizeForItemAt() -> CGSize
    func didSelectContextMenuConfiguration(_ index: Int)
    func scrollViewDidScroll()

    func numberOfItemsInSection() -> Int
    func numberOfSections() -> Int
    func cellForRowAt(_ index: Int) -> Movie
}

final class MXComingSoonViewModel: MXUserDefaultsManager {
    weak var view: MXComingSoonViewControllerProtocol?
    private var isLoadingMoreMovies: Bool = false
    private var movieResponse: MovieResponse?
    private var movies: [Movie] = []

    private func fetchMovies(page: String) {
        guard !isLoadingMoreMovies else {
            return
        }

        isLoadingMoreMovies = true

        APIClient.shared.execute(TMDBRequest.fetchUpcomingMovies(page).urlRequest(),
                                 expecting: MovieResponse.self)
        { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let newMovieResponse):
                guard self.movieResponse != newMovieResponse else {
                    self.isLoadingMoreMovies = false
                    return
                }
                self.movieResponse = newMovieResponse
                self.movies.append(contentsOf: newMovieResponse.results)

                DispatchQueue.main.async {
                    self.view?.reloadCollectionView()
                    self.isLoadingMoreMovies = false
                }
            case .failure(let error):
                print(error.description)
                self.isLoadingMoreMovies = false
            }
        }
    }
}

// MARK: - Controller + MAComingSoonViewModelProtocol

extension MXComingSoonViewModel: MXComingSoonViewModelProtocol {
    func viewDidLoad() {
        view?.prepareView()
        view?.prepareCollectionView()
    }

    func viewWillAppear() {
        fetchMovies(page: movieResponse?.page.description ?? "1")
    }

    func didSelectItemAt(_ index: Int) {
        let movie = movies[index]

        guard let titleName = movie.original_title ?? movie.original_name else {
            return
        }

        let request = YTRequest.searchRequest(titleName + "trailer").urlRequest()

        APIClient.shared.execute(request,
                                 expecting: YoutubeSearchResponse.self)
        { [weak self] result in
            switch result {
            case .success(let videoElement):
                let movieDetailModel = MovieDetail(
                    id: movie.id,
                    title: movie.original_title ?? movie.original_name,
                    overview: movie.overview,
                    youtubeVideo: videoElement.items.first)

                DispatchQueue.main.async {
                    self?.view?.push(MXMovieDetailViewController(
                        movie: movie,
                        movieDetail: movieDetailModel))
                }
            case .failure(let error):
                print(error.description)
            }
        }
    }

    func sizeForItemAt() -> CGSize {
        guard let view else { return .zero }
        return CGSize(width: view.frame.width, height: view.frame.width * 0.318)
    }

    func didSelectContextMenuConfiguration(_ index: Int) {
        let movie = movies[index]

        update(.add, movie: movie) { [weak self] error in
            self?.view?.alert(
                title: error == nil ? "Congratulations!" : "Error!",
                message: error == nil ? "Movie added successfully" : error?.description ?? "An error occured.",
                actionTitle: "OK")
        }
    }

    func scrollViewDidScroll() {
        guard let page = movieResponse?.page,
              let totalPages = movieResponse?.totalPages,
              page < totalPages, !isLoadingMoreMovies else { return }

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] timer in
            guard let self,
                  let view else { return }

            if view.contentOffset >= (view.totalContentHeight - view.scroolHeight - 120) {
                self.fetchMovies(page: "\(page + 1)")
            }

            timer.invalidate()
        }
    }

    func numberOfItemsInSection() -> Int {
        movies.count
    }

    func numberOfSections() -> Int {
        1
    }

    func cellForRowAt(_ index: Int) -> Movie {
        movies[index]
    }
}
