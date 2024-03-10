//
//  MXComingSoonViewController.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import UIKit

protocol MXComingSoonViewControllerProtocol: AnyObject, Pushable, Alertable {
    var searchText: String? { get }

    var frame: CGRect { get }
    var scroolHeight: CGFloat { get }
    var contentOffset: CGFloat { get }
    var totalContentHeight: CGFloat { get }

    func prepareView()
    func prepareSearchController()
    func prepareCollectionView()
    func reloadCollectionView()
    func showLoadingView()
    func dismissLoadingView()
}

final class MXComingSoonViewController: MXRefreshableViewController {
    private lazy var viewModel: MXComingSoonViewModelProtocol = MXComingSoonViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<MXDiscoveryViewModel.Section, Movie>!

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
}

// MARK: -  Controller + MAComingSoonViewControllerProtocol

extension MXComingSoonViewController: MXComingSoonViewControllerProtocol {
    var searchText: String? {
        navigationItem.searchController?.searchBar.text
    }

    var scroolHeight: CGFloat {
        collectionView.frame.height
    }

    var contentOffset: CGFloat {
        collectionView.contentOffset.y
    }

    var totalContentHeight: CGFloat {
        collectionView.contentSize.height
    }

    var frame: CGRect {
        view.frame
    }

    func prepareView() {
        view.backgroundColor = .systemBackground
        title = "Coming Soon"
    }

    func prepareCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func prepareSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a movie..."
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }

    func reloadCollectionView() {
        collectionView.reloadData()
    }

    func showLoadingView() {
        startRefreshing()
    }

    func dismissLoadingView() {
        stopRefreshing()
    }
}

// MARK: -  Controller + UICollectionViewDataSource

extension MXComingSoonViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsInSection()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MXMovieCollectionCell.identifier,
            for: indexPath) as? MXMovieCollectionCell
        else {
            fatalError()
        }

        cell.configure(with: viewModel.cellForRowAt(indexPath.row))
        return cell
    }
}

// MARK: -  Controller + UICollectionViewDelegate

extension MXComingSoonViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItemAt(indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let downloadAction = UIAction(title: "Download", state: .off) { _ in
                if let indexPath = indexPaths.first {
                    self?.viewModel.didSelectContextMenuConfiguration(indexPath.row)
                }
            }
            return .init(title: "", options: .destructive, children: [downloadAction])
        }
        return config
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.scrollViewDidScroll()
    }
}

// MARK: -  Controller + UICollectionViewDelegateFlowLayout

extension MXComingSoonViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        viewModel.sizeForItemAt()
    }
}

// MARK: - Controller + UISearchControllerDelegate, UISearchBarDelegate

extension MXComingSoonViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearchResults()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchBarCancelButtonClicked()
    }
}
