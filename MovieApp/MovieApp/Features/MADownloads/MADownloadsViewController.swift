//
//  MADownloadsViewController.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import UIKit

protocol MADownloadsViewControllerProtocol: AnyObject, Pushable {
    // MARK: - Variables

    var frame: CGRect { get }

    // MARK: - Functions

    func prepareView()
    func prepareCollectionView()
    func reloadCollectionView()
}

final class MADownloadsViewController: UIViewController {
    // MARK: - Variables

    private lazy var viewModel: MADownloadsViewModelProtocol = MADownloadsViewModel()

    var frame: CGRect {
        view.frame
    }

    // MARK: - UI Components

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MAMovieCollectionCell.self,
                                forCellWithReuseIdentifier: MAMovieCollectionCell.identifier)
        return collectionView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.viewWillAppear()
    }
}

// MARK: - Controller + MADownloadsViewControllerProtocol

extension MADownloadsViewController: MADownloadsViewControllerProtocol {
    func prepareView() {
        view.backgroundColor = .systemBackground
        title = "Downloads"
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

    func reloadCollectionView() {
        collectionView.reloadData()
    }
}

// MARK: -  Controller + UICollectionViewDataSource

extension MADownloadsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsInSection()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MAMovieCollectionCell.identifier,
                                                            for: indexPath) as? MAMovieCollectionCell
        else {
            fatalError()
        }

        cell.configure(with: viewModel.cellForRowAt(indexPath.row))

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItemAt(indexPath.row)
    }
}

// MARK: -  Controller + UICollectionViewDelegate

extension MADownloadsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let deleteAction = UIAction(title: "Delete", state: .off) { _ in
                if let indexPath = indexPaths.first {
                    self?.viewModel.didSelectContextMenuConfiguration(indexPath.row)
                }
            }
            return .init(title: "", options: .destructive, children: [deleteAction])
        }
        return config
    }
}

// MARK: -  Controller + UICollectionViewDelegateFlowLayout

extension MADownloadsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        viewModel.sizeForItemAt()
    }
}
