//
//  MXDownloadsViewModel.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 6.03.2024.
//

import Foundation

protocol MXDownloadsViewModelProtocol {
    var view: MXDownloadsViewControllerProtocol? { get set }

    func viewDidLoad()
    func viewWillAppear()
    func didSelectItemAt(_ index: Int)
    func sizeForItemAt() -> CGSize
    func didSelectContextMenuConfiguration(_ index: Int)

    func numberOfItemsInSection() -> Int
    func numberOfSections() -> Int
    func cellForRowAt(_ index: Int) -> Movie
}

final class MXDownloadsViewModel: MXUserDefaultsManager {
    weak var view: MXDownloadsViewControllerProtocol?
    private var movies: [Movie] = []

    private func fetchMovies() {
        fetch(.downloads) { [weak self] result in
            switch result {
            case .success(let models):
                self?.movies = models
                self?.view?.reloadCollectionView()
            case .failure(let error):
                print(error.description)
            }
        }
    }
}

// MARK: - ViewModel + MADownloadsViewModelProtocol

extension MXDownloadsViewModel: MXDownloadsViewModelProtocol {
    func viewDidLoad() {
        view?.prepareView()
        view?.prepareCollectionView()
    }

    func viewWillAppear() {
        fetchMovies()
    }

    func didSelectItemAt(_ index: Int) {
        let movie = movies[index]
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
                    self?.view?.push(MXMovieDetailViewController(movie: movie, movieDetail: movieDetailModel))
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

        update(.remove, movie: movie) { [weak self] error in
            guard error == nil else { print(error?.description ?? ""); return }

            self?.movies.remove(at: index)
            self?.view?.reloadCollectionView()
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
