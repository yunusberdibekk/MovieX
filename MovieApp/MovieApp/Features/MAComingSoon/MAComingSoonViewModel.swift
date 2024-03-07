//
//  MAComingSoonViewModel.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 7.03.2024.
//

import Foundation

protocol MAComingSoonViewModelProtocol {
    // MARK: - Variables

    var view: MAComingSoonViewControllerProtocol? { get set }

    // MARK: - Functions

    func viewDidLoad()
    func viewWillAppear()
    func didSelectItemAt(_ index: Int)
    func sizeForItemAt() -> CGSize
    func didSelectContextMenuConfiguration(_ index: Int)

    func numberOfItemsInSection() -> Int
    func numberOfSections() -> Int
    func cellForRowAt(_ index: Int) -> Movie
}

final class MAComingSoonViewModel: MAUserDefaultsManager {
    // MARK: - Variables

    weak var view: MAComingSoonViewControllerProtocol?
    private var movieResponse: MAMovieResponse?
    private var movies: [Movie] = []

    private func fetchMovies(page: String) {
        APIClient.shared.execute(TMDBRequest.fetchUpcomingMovies(page).urlRequest(),
                                 expecting: MAMovieResponse.self)
        { [weak self] result in
            switch result {
            case .success(let movieResponse):
                self?.movieResponse = movieResponse
                self?.movies = movieResponse.results
                DispatchQueue.main.async {
                    self?.view?.reloadCollectionView()
                }
            case .failure(let error):
                print(error.description)
            }
        }
    }
}

// MARK: - Controller + MAComingSoonViewModelProtocol

extension MAComingSoonViewModel: MAComingSoonViewModelProtocol {
    func viewDidLoad() {
        view?.prepareView()
        view?.prepareCollectionView()
    }

    func viewWillAppear() {
        fetchMovies(page: movieResponse?.page.description ?? "1")
    }

    func didSelectItemAt(_ index: Int) {
        let movie = movies[index]
        guard let titleName = movie.original_title ?? movie.original_name else { return }
        let request = YTRequest.searchRequest(titleName + "trailer").urlRequest()

        APIClient.shared.execute(request,
                                 expecting: MAYoutubeSearchResponse.self)
        { [weak self] result in
            switch result {
            case .success(let videoElement):
                let movieDetailModel = MAMovieDetail(
                    id: movie.id,
                    title: movie.original_title ?? movie.original_name,
                    overview: movie.overview,
                    youtubeVideo: videoElement.items.first)

                DispatchQueue.main.async {
                    self?.view?.push(MAMovieDetailViewController(movie: movie, movieDetail: movieDetailModel))
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

        // like showcasevc
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
