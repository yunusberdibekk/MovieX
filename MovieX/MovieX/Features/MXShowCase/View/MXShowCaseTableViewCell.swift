//
//  MXShowCaseTableViewCell.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import UIKit

protocol MXShowCaseTableViewCellProtocol: AnyObject {
    func didSelectRow(_ movie: Movie)
    func didTapDownloadAction(_ movie: Movie?)
}

final class MXShowCaseTableViewCell: UITableViewCell {
    static let identifier: String = "MXShowCaseTableViewCell"
    weak var delegate: MXShowCaseTableViewCellProtocol?
    private var movies: [Movie] = []

    // MARK: -  UI Components

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 200)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            MXShowCaseCollectionCell.self,
            forCellWithReuseIdentifier: MXShowCaseCollectionCell.identifier)
        return collectionView
    }()

    // MARK: -  Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareCollectionView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func prepareCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalToSystemSpacingBelow: topAnchor,
                multiplier: 0),
            collectionView.leadingAnchor.constraint(
                equalToSystemSpacingAfter: leadingAnchor,
                multiplier: 0),
            trailingAnchor.constraint(
                equalToSystemSpacingAfter: collectionView.trailingAnchor,
                multiplier: 0),
            bottomAnchor.constraint(
                equalToSystemSpacingBelow: collectionView.bottomAnchor,
                multiplier: 0)
        ])
    }
}

extension MXShowCaseTableViewCell {
    public func configure(with movies: [Movie]) {
        self.movies = movies
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

// MARK: - TableViewCell + UICollectionViewDataSource

extension MXShowCaseTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MXShowCaseCollectionCell.identifier,
            for: indexPath) as? MXShowCaseCollectionCell else { fatalError() }

        cell.configure(movie: movies[indexPath.row])
        return cell
    }
}

// MARK: - TableViewCell + UICollectionViewDelegate

extension MXShowCaseTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelectRow(movies[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil)
        { [weak self] _ in
            let downloadAction = UIAction(title: "Download", state: .off) { _ in
                if let indexpath = indexPaths.first {
                    self?.delegate?.didTapDownloadAction(self?.movies[indexpath.row])
                }
            }
            return UIMenu(title: "", options: .singleSelection, children: [downloadAction])
        }
        return config
    }
}
