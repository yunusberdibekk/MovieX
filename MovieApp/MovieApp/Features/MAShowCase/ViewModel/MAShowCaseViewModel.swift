//
//  MAShowCaseViewModel.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import Foundation

protocol MAShowCaseViewModelProtocol {
    // MARK: - Variables

    var view: MAShowCaseViewControllerProtocol? { get set }

    // MARK: - Functions

    func viewDidLoad()
    func viewWillAppear()
    func viewForHeader()
    func didSelectRowAt(_ movie: Movie)
    func didSelectContextMenuConfiguration(_ movie: Movie?)
    func titleForHeaderInSection(_ section: Int) -> String?
    func heightForRowAt() -> CGFloat
    func heightForRowInSection() -> CGFloat

    func numberOfRowsInSection() -> Int
    func numberOfSections() -> Int
    func cellForRowAt(_ section: Int, completion: @escaping (Result<MAMovieResponse, APIClientError>) -> Void)
}

final class MAShowCaseViewModel: MAUserDefaultsManager {
    // MARK: - Variables

    enum Sections: Int, CaseIterable {
        case trendingTv
        case trendingMovie
        case popular
        case upcoming
        case topRated

        var title: String {
            switch self {
            case .trendingTv:
                "Trending TV Series"
            case .trendingMovie:
                "Trending Movies"
            case .upcoming:
                "Upcoming Movies"
            case .topRated:
                "Top Rated Movies"
            case .popular:
                "Popular Series"
            }
        }
    }

    weak var view: MAShowCaseViewControllerProtocol?
}

// MARK: - ViewModel + MAShowCaseViewModelDelegate

extension MAShowCaseViewModel: MAShowCaseViewModelProtocol {
    func viewDidLoad() {
        view?.prepareViewController()
        view?.prepareTableView()
    }

    func viewWillAppear() {}

    func viewForHeader() {
        APIClient.shared.execute(TMDBRequest.fetchTrendingMovies.urlRequest(), expecting: MAMovieResponse.self) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.view?.movieTableHeaderView?.configure(movie: movies.results.randomElement())
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func didSelectRowAt(_ movie: Movie) {
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
                    self?.view?.push(MAMovieDetailViewController(
                        movie: movie,
                        movieDetail: movieDetailModel))
                }
            case .failure(let error):
                print(error.description)
            }
        }
    }

    func didSelectContextMenuConfiguration(_ movie: Movie?) {
        guard let movie else { return }

        update(.add, movie: movie) { [weak self] error in
            self?.view?.alert(
                title: error == nil ? "Congratulations!" : "Error!",
                message: error == nil ? "Movie added successfully" : error?.description ?? "An error occured.",
                actionTitle: "OK")
        }
    }

    func titleForHeaderInSection(_ section: Int) -> String? {
        return Sections.allCases[section].title
    }

    func heightForRowAt() -> CGFloat {
        (view?.frame.width ?? .zero) * 0.5
    }

    func heightForRowInSection() -> CGFloat {
        (view?.frame.width ?? .zero) * 0.1
    }

    func numberOfSections() -> Int {
        Sections.allCases.count
    }

    func numberOfRowsInSection() -> Int {
        1
    }

    func cellForRowAt(_ section: Int, completion: @escaping (Result<MAMovieResponse, APIClientError>) -> Void) {
        let section = Sections.allCases[section]

        switch section {
        case .trendingTv:
            APIClient.shared.execute(
                TMDBRequest.fetchTrendingTvSeries.urlRequest(),
                expecting: MAMovieResponse.self,
                completion: completion)
        case .trendingMovie:
            APIClient.shared.execute(
                TMDBRequest.fetchTrendingMovies.urlRequest(),
                expecting: MAMovieResponse.self,
                completion: completion)
        case .upcoming:
            APIClient.shared.execute(
                TMDBRequest.fetchUpcomingMovies("1").urlRequest(),
                expecting: MAMovieResponse.self,
                completion: completion)
        case .popular:
            APIClient.shared.execute(
                TMDBRequest.fetchPopularMovies.urlRequest(),
                expecting: MAMovieResponse.self,
                completion: completion)
        case .topRated:
            APIClient.shared.execute(
                TMDBRequest.fetchTopRatedMovies.urlRequest(),
                expecting: MAMovieResponse.self,
                completion: completion)
        }
    }
}
