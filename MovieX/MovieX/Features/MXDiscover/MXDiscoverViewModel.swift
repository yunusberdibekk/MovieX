//
//  MATopSearchViewModel.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 9.03.2024.
//

import Foundation

protocol MXDiscoverViewModelProtocol {
    var view: MXDiscoverViewControllerProtocol? { get set }

    func viewDidLoad()
    func viewWillAppear()
    func didSelectItemAt(_ index: Int)
    func sizeForItemAt() -> CGSize
    func didSelectContextMenuConfiguration(_ index: Int)
    func cellForRowAt(_ index: Int) -> Movie

    func updateSearchResults()
}

final class MXDiscoverViewModel: MXUserDefaultsManager {
    // MARK: - Variables

    enum Section {
        case main
    }

    weak var view: MXDiscoverViewControllerProtocol?
    private var isLoadingMoreMovies: Bool = false
    private var movieResponse: MovieResponse?
    private var movies: [Movie] = []
    private var filteredMovies: [Movie] = []

    private func fetchDiscoverMovies() {
        APIClient.shared.execute(
            TMDBRequest.fetchDiscoverMovies.urlRequest(),
            expecting: MovieResponse.self)
        { [weak self] result in
            switch result {
            case .success(let newMovieResponse):
                self?.movieResponse = newMovieResponse
                self?.movies = newMovieResponse.results

                DispatchQueue.main.async {
                    self?.view?.reloadCollectionView(on: newMovieResponse.results)
                }
            case .failure(let error):
                print(error.description)
            }
        }
    }
}

// MARK: - ViewModel + MATopSearchViewModelProtocol.

extension MXDiscoverViewModel: MXDiscoverViewModelProtocol {
    func viewDidLoad() {
        view?.prepareView()
        view?.prepareSearchController()
        view?.prepareCollectionView()
        view?.prepareDataSource()
    }

    func viewWillAppear() {
        fetchDiscoverMovies()
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

    func cellForRowAt(_ index: Int) -> Movie {
        movies[index]
    }

    func updateSearchResults() {
        guard let text = view?.searchText,
              !text.isEmpty
        else {
            filteredMovies.removeAll()
            view?.reloadCollectionView(on: movies)
            return
        }

        filteredMovies = movies.filter { movie in
            guard let movieName = movie.original_name ?? movie.original_title else {
                return false
            }
            return movieName.contains(text.lowercased())
        }

        view?.reloadCollectionView(on: filteredMovies)
    }
}
