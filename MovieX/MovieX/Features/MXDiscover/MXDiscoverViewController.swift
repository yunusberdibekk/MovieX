//
//  MADiscoverViewController.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import UIKit

protocol MXDiscoverViewControllerProtocol: AnyObject, Alertable, Pushable {
    var frame: CGRect { get }
    var searchText: String? { get }

    func prepareView()
    func prepareSearchController()
    func prepareCollectionView()
    func reloadCollectionView(on movies: [Movie])
    func prepareDataSource()
}

final class MXDiscoverViewController: UIViewController {
    private lazy var viewModel: MXDiscoverViewModelProtocol = MXDiscoverViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<MXDiscoverViewModel.Section, Movie>!

    // MARK: - UI Components

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MXMovieCollectionCell.self,
                                forCellWithReuseIdentifier: MXMovieCollectionCell.identifier)

        return collectionView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
}

extension MXDiscoverViewController: MXDiscoverViewControllerProtocol {
    var frame: CGRect {
        view.frame
    }

    var searchText: String? {
        navigationItem.searchController?.searchBar.text
    }

    func prepareView() {
        view.backgroundColor = .systemBackground
        title = "Discover"
    }

    func prepareSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a movie..."
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }

    func prepareCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    func prepareDataSource() {
        dataSource = UICollectionViewDiffableDataSource<MXDiscoverViewModel.Section, Movie>(collectionView: collectionView, cellProvider: { collectionView, indexPath, movie in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MXMovieCollectionCell.identifier,
                for: indexPath) as? MXMovieCollectionCell
            else {
                fatalError()
            }

            cell.configure(with: movie)
            return cell
        })
    }

    func reloadCollectionView(on movies: [Movie]) {
        var snapshot = NSDiffableDataSourceSnapshot<MXDiscoverViewModel.Section, Movie>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movies)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

// MARK: - Controller + UICollectionViewDelegate

extension MXDiscoverViewController: UICollectionViewDelegate {}

extension MXDiscoverViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        viewModel.sizeForItemAt()
    }
}

// MARK: - Controller + UISearchControllerDelegate, UISearchBarDelegate

extension MXDiscoverViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearchResults()
    }
}
