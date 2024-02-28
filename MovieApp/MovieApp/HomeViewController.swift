//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 27.02.2024.
//

import UIKit

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

final class HomeViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            MovieTableViewCell.self,
            forCellReuseIdentifier: MovieTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        prepareTableView()
    }

    private func prepareTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.tableHeaderView = MovieTableHeaderView(
            frame: .init(x: .zero, y: .zero, width: view.frame.width, height: view.frame.height * 0.70))
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor,
                multiplier: 0),
            tableView.leadingAnchor.constraint(
                equalToSystemSpacingAfter: view.leadingAnchor,
                multiplier: 0),
            view.trailingAnchor.constraint(
                equalToSystemSpacingAfter: tableView.trailingAnchor,
                multiplier: 0),
            view.bottomAnchor.constraint(
                equalToSystemSpacingBelow: tableView.bottomAnchor,
                multiplier: 0)
        ])
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        Sections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else { fatalError() }
        let section = Sections.allCases[indexPath.section]

        switch section {
        case .trendingTv:
            let request = APIRequest.fetchTrendingTvSeries.urlRequest
            APIClient.shared.execute(request, expecting: MovieResponse.self) { result in
                switch result {
                case .success(let response):
                    cell.configure(with: response.results)
                case .failure(let error):
                    print(error.description)
                }
            }
        case .trendingMovie:
            let request = APIRequest.fetchTrendingMovies.urlRequest
            APIClient.shared.execute(request, expecting: MovieResponse.self) { result in
                switch result {
                case .success(let response):
                    cell.configure(with: response.results)
                case .failure(let error):
                    print(error.description)
                }
            }
        case .upcoming:
            let request = APIRequest.fetchUpcomingMovies.urlRequest
            APIClient.shared.execute(request, expecting: MovieResponse.self) { result in
                switch result {
                case .success(let response):
                    cell.configure(with: response.results)
                case .failure(let error):
                    print(error.description)
                }
            }
        case .popular:
            let request = APIRequest.fetchPopularMovies.urlRequest
            APIClient.shared.execute(request, expecting: MovieResponse.self) { result in
                switch result {
                case .success(let response):
                    cell.configure(with: response.results)
                case .failure(let error):
                    print(error.description)
                }
            }
        case .topRated:
            let request = APIRequest.fetchTopRatedMovies.urlRequest
            APIClient.shared.execute(request, expecting: MovieResponse.self) { result in
                switch result {
                case .success(let response):
                    cell.configure(with: response.results)
                case .failure(let error):
                    print(error.description)
                }
            }
        }

        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        35
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Sections.allCases[section].title
    }
}
