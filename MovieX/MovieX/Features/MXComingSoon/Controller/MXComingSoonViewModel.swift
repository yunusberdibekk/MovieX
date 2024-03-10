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
    func updateSearchResults()
    func searchBarCancelButtonClicked()
    func numberOfItemsInSection() -> Int
    func numberOfSections() -> Int
    func cellForRowAt(_ index: Int) -> Movie
    func didSelectItemAt(_ index: Int)
    func didSelectContextMenuConfiguration(_ index: Int)
    func sizeForItemAt() -> CGSize
    func scrollViewDidScroll()
}

final class MXComingSoonViewModel: MXUserDefaultsManager {
    enum Section {
        case main
    }

    weak var view: MXComingSoonViewControllerProtocol?
    private var isLoadingMoreMovies: Bool = false
    private var movieResponse: MovieResponse?
    private var movies: [Movie] = []
    private var searchedMovies: [Movie] = []

    private func fetchMovies(page: String) {
        guard !isLoadingMoreMovies else {
            return
        }

        view?.showLoadingView()
        isLoadingMoreMovies = true

        APIClient.shared.execute(TMDBRequest.fetchUpcomingMovies(page).urlRequest(),
                                 expecting: MovieResponse.self)
        { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let newMovieResponse):
                guard self.movieResponse != newMovieResponse else {
                    updateUI()
                    return
                }

                self.movieResponse = newMovieResponse
                self.movies.append(contentsOf: newMovieResponse.results)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.view?.reloadCollectionView()
                    self.updateUI()
                }
            case .failure(let error):
                updateUI()
                view?.alert(
                    title: "Error!",
                    message: error.description,
                    actionTitle: "OK")
            }
        }
    }

    private func updateUI() {
        view?.dismissLoadingView()
        isLoadingMoreMovies = false
    }
}

// MARK: - Controller + MAComingSoonViewModelProtocol

extension MXComingSoonViewModel: MXComingSoonViewModelProtocol {
    var isSearching: Bool {
        !(view?.searchText?.isEmpty ?? true)
    }

    func viewDidLoad() {
        view?.prepareView()
        view?.prepareSearchController()
        view?.prepareCollectionView()
        fetchMovies(page: "1")
    }

    func updateSearchResults() {
        guard let query = view?.searchText,
              !query.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            searchedMovies.removeAll()
            view?.reloadCollectionView()
            return
        }

        searchedMovies = movies.filter { movie in
            guard let movieName = movie.original_name ?? movie.original_title else { return false }
            guard movieName.contains(query) else { return false }

            return true
        }

        view?.reloadCollectionView()
    }

    func searchBarCancelButtonClicked() {
        searchedMovies.removeAll()
        view?.reloadCollectionView()
    }

    func numberOfItemsInSection() -> Int {
        isSearching ? searchedMovies.count : movies.count
    }

    func numberOfSections() -> Int {
        1
    }

    func cellForRowAt(_ index: Int) -> Movie {
        isSearching ? searchedMovies[index] : movies[index]
    }

    func didSelectItemAt(_ index: Int) {
        let movie = isSearching ? searchedMovies[index] : movies[index]

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

    func didSelectContextMenuConfiguration(_ index: Int) {
        let movie = isSearching ? searchedMovies[index] : movies[index]

        update(.add, movie: movie) { [weak self] error in
            self?.view?.alert(
                title: error == nil ? "Congratulations!" : "Error!",
                message: error == nil ? "Movie added successfully" : error?.description ?? "An error occured.",
                actionTitle: "OK")
        }
    }

    func sizeForItemAt() -> CGSize {
        guard let view else { return .zero }
        return CGSize(width: view.frame.width, height: view.frame.width * 0.318)
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
}
