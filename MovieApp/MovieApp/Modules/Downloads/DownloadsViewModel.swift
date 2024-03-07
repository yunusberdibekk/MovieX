//
//  DownloadsViewModel.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 6.03.2024.
//

import Foundation

protocol DownloadsViewModelProtocol {
    var view: DownloadsViewControllerProtocol? { get set }

    func viewDidLoad()
    func viewWillAppear()
    func numberOfItemsInSection() -> Int
    func cellForRowAt(_ index: Int) -> Movie
    func didSelectItemAt(_ index: Int)
    func sizeForItemAt() -> CGSize
    func didTapDeleteAction(_ index: Int)
}

final class DownloadsViewModel: DownloadsViewModelProtocol {
    weak var view: DownloadsViewControllerProtocol?
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

extension DownloadsViewModel {
    func viewDidLoad() {
        view?.prepareView()
        view?.prepareCollectionView()
    }

    func viewWillAppear() {
        fetchMovies()
    }

    func numberOfItemsInSection() -> Int {
        movies.count
    }

    func cellForRowAt(_ index: Int) -> Movie {
        movies[index]
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
                    self?.view?.push(MovieDetailViewController(
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

    func didTapDeleteAction(_ index: Int) {
        let movie = movies[index]

        update(.remove, movie: movie) { [weak self] error in
            guard error == nil else { print(error?.description ?? ""); return }

            self?.movies.remove(at: index)
            self?.view?.reloadCollectionView()
        }
    }
}

extension DownloadsViewModel: DownloadsDefaultsManagerProtocol {}
