//
//  MXDiscoveryViewModel.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 9.03.2024.
//

import Foundation

protocol MXDiscoverViewModelProtocol {
    var view: MXDiscoveryViewControllerProtocol? { get set }

    func viewDidLoad()
    func didSelectItemAt(_ index: Int)
    func sizeForItemAt() -> CGSize
    func didSelectContextMenuConfiguration(_ index: Int)
    func updateSearchResults()
    func searchBarCancelButtonClicked()
}

final class MXDiscoveryViewModel: MXUserDefaultsManager {
    enum Section {
        case main
    }

    // MARK: - Variables

    weak var view: MXDiscoveryViewControllerProtocol?
    private var movies: [Movie] = []
    private var searchedMovies: [Movie] = []

    private func fetchDiscoverMovies() {
        APIClient.shared.execute(
            TMDBRequest.fetchDiscoverMovies.urlRequest(),
            expecting: MovieResponse.self)
        { [weak self] result in
            switch result {
            case .success(let newMovieResponse):
                self?.movies = newMovieResponse.results

                DispatchQueue.main.async {
                    self?.view?.reloadCollectionView(on: newMovieResponse.results)
                }
            case .failure(let error):
                print(error.description)
            }
        }
    }

    private func fetchQueryMovies(query: String) {
        APIClient.shared.execute(
            TMDBRequest.search(query).urlRequest(),
            expecting: MovieResponse.self)
        { [weak self] result in
            switch result {
            case .success(let newMovieResponse):
                guard !newMovieResponse.results.isEmpty else { return }
                self?.searchedMovies = newMovieResponse.results

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

extension MXDiscoveryViewModel: MXDiscoverViewModelProtocol {
    var isSearching: Bool {
        !(view?.searchText?.isEmpty ?? true)
    }

    func viewDidLoad() {
        view?.prepareView()
        view?.prepareSearchController()
        view?.prepareCollectionView()
        view?.prepareDataSource()
        fetchDiscoverMovies()
    }

    func didSelectItemAt(_ index: Int) {
        let movie = isSearching ? searchedMovies[index] : movies[index]
        guard let titleName = movie.original_title ?? movie.original_name else { return }
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
        let movie = isSearching ? searchedMovies[index] : movies[index]

        update(.add, movie: movie) { [weak self] error in
            self?.view?.alert(
                title: error == nil ? "Congratulations!" : "Error!",
                message: error == nil ? "Movie added successfully" : error?.description ?? "An error occured.",
                actionTitle: "OK")
        }
    }

    func updateSearchResults() {
        guard let query = view?.searchText,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3
        else {
            searchedMovies.removeAll()
            view?.reloadCollectionView(on: movies)
            return
        }

        fetchQueryMovies(query: query)
    }

    func searchBarCancelButtonClicked() {
        searchedMovies.removeAll()
        view?.reloadCollectionView(on: movies)
    }
}
