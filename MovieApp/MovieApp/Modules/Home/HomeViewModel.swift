//
//  HomeViewModel.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import Foundation

protocol HomeViewModelProtocol {
    var view: HomeViewControllerProtocol? { get set }

    func viewDidLoad()
    func viewWillAppear()
    func tableHeaderView()
    func numberOfSections() -> Int
    func numberOfRowsInSection() -> Int
    func cellForRowAt(_ section: Int, completion: @escaping (Result<MovieResponse, APIClientError>) -> Void)
    func didSelectRow(_ movie: Movie)
    func didTapDownloadAction(_ movie: Movie?)
    func titleForHeaderInSection(_ section: Int) -> String?
    func heightForRowAt() -> CGFloat
    func heightForHeaderInSection() -> CGFloat
}

final class HomeViewModel {
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

    weak var view: HomeViewControllerProtocol?
}

extension HomeViewModel: HomeViewModelProtocol {
    func viewDidLoad() {
        view?.prepareViewController()
        view?.prepareTableView()
    }

    func viewWillAppear() {}

    func tableHeaderView() {
        APIClient.shared.execute(TMDBRequest.fetchTrendingMovies.urlRequest(), expecting: MovieResponse.self) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.view?.movieTableHeaderView?.configure(movie: movies.results.randomElement())
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func numberOfSections() -> Int {
        Sections.allCases.count
    }

    func numberOfRowsInSection() -> Int {
        1
    }

    func cellForRowAt(_ section: Int, completion: @escaping (Result<MovieResponse, APIClientError>) -> Void) {
        let section = Sections.allCases[section]

        switch section {
        case .trendingTv:
            APIClient.shared.execute(
                TMDBRequest.fetchTrendingTvSeries.urlRequest(),
                expecting: MovieResponse.self,
                completion: completion)
        case .trendingMovie:
            APIClient.shared.execute(
                TMDBRequest.fetchTrendingMovies.urlRequest(),
                expecting: MovieResponse.self,
                completion: completion)
        case .upcoming:
            APIClient.shared.execute(
                TMDBRequest.fetchUpcomingMovies.urlRequest(),
                expecting: MovieResponse.self,
                completion: completion)
        case .popular:
            APIClient.shared.execute(
                TMDBRequest.fetchPopularMovies.urlRequest(),
                expecting: MovieResponse.self,
                completion: completion)
        case .topRated:
            APIClient.shared.execute(
                TMDBRequest.fetchTopRatedMovies.urlRequest(),
                expecting: MovieResponse.self,
                completion: completion)
        }
    }

    func didSelectRow(_ movie: Movie) {
        guard let titleName = movie.original_title ?? movie.original_name else { return }
        let request = YTRequest.searchRequest(titleName + "trailer").urlRequest()
        dump(request)
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
                    self?.view?.push(MovieDetailViewController(
                        movie: movie,
                        movieDetail: movieDetailModel))
                }
            case .failure(let error):
                print("leooo")
                print(error.description)
            }
        }
    }

    func didTapDownloadAction(_ movie: Movie?) {
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
        return (view?.frame.width ?? .zero) * 0.5
    }

    func heightForHeaderInSection() -> CGFloat {
        return (view?.frame.width ?? .zero) * 0.1
    }
}

extension HomeViewModel: DownloadsDefaultsManagerProtocol {}
