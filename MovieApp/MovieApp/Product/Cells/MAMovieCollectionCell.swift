//
//  MAMovieCollectionCell.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 6.03.2024.
//

import SDWebImage
import UIKit

final class MAMovieCollectionCell: UICollectionViewCell {
    // MARK: - Variables

    static let identifier: String = "MAMovieCollectionCell"

    // MARK: - UI Components

    private let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(resource: .defaultCell)
        return imageView
    }()

    private let movieLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "Venom"
        return label
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        return view
    }()

    // MARK: -  Lifecycle

    override init(frame: CGRect) {
        super.init(frame: .zero)
        prepareImageView()
        prepareLabel()
        prepareDivider()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func prepareImageView() {
        addSubview(movieImageView)

        NSLayoutConstraint.activate([
            movieImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            movieImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            movieImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.95),
            movieImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
        ])
    }

    private func prepareLabel() {
        addSubview(movieLabel)

        NSLayoutConstraint.activate([
            movieLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            movieLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            movieLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.68),
        ])
    }

    private func prepareDivider() {
        addSubview(dividerView)

        NSLayoutConstraint.activate([
            dividerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4),
            dividerView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}

extension MAMovieCollectionCell {
    public func configure(with movie: Movie) {
        movieLabel.text = movie.original_title ?? movie.original_name

        guard let path = movie.poster_path, let url = URL(string: "https://image.tmdb.org/t/p/w500/\(path)") else {
            return
        }

        movieImageView.sd_setImage(with: url, completed: nil)
    }
}
