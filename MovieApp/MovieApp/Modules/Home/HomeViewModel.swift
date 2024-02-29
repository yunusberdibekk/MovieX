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
        let request = APIRequest.fetchTrendingMovies.urlRequest
        APIClient.shared.execute(request, expecting: MovieResponse.self) { [weak self] result in
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
            let request = APIRequest.fetchTrendingTvSeries.urlRequest
            APIClient.shared.execute(request, expecting: MovieResponse.self, completion: completion)
        case .trendingMovie:
            let request = APIRequest.fetchTrendingMovies.urlRequest
            APIClient.shared.execute(request, expecting: MovieResponse.self, completion: completion)
        case .upcoming:
            let request = APIRequest.fetchUpcomingMovies.urlRequest
            APIClient.shared.execute(request, expecting: MovieResponse.self, completion: completion)
        case .popular:
            let request = APIRequest.fetchPopularMovies.urlRequest
            APIClient.shared.execute(request, expecting: MovieResponse.self, completion: completion)
        case .topRated:
            let request = APIRequest.fetchTopRatedMovies.urlRequest
            APIClient.shared.execute(request, expecting: MovieResponse.self, completion: completion)
        }
    }

    func didSelectRow(_ movie: Movie) {
        guard let titleName = movie.original_title ?? movie.original_name, let request = YTRequest.searchRequest(titleName + "trailer") else { return }

        APIClient.shared.execute(request, expecting: YoutubeSearchResponse.self) { [weak self] result in
            switch result {
            case .success(let videoElement):
                let movieDetailModel = MovieDetail(
                    id: movie.id,
                    title: movie.original_title ?? movie.original_name,
                    overview: movie.overview,
                    youtubeVideo: videoElement.items.first)

                DispatchQueue.main.async {
                    self?.view?.push(MovieDetailViewController(movieDetail: movieDetailModel))
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
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
