//
//  MovieCollectionViewCell.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import SDWebImage
import UIKit

final class MovieCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "MovieCollectionViewCell"

    private let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .defaultCell)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareMovieImageView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func prepareMovieImageView() {
        addSubview(movieImageView)

        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0),
            movieImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0),
            trailingAnchor.constraint(equalToSystemSpacingAfter: movieImageView.trailingAnchor, multiplier: 0),
            bottomAnchor.constraint(equalToSystemSpacingBelow: movieImageView.bottomAnchor, multiplier: 0)
        ])
    }
}

extension MovieCollectionViewCell {
    public func configure(movie: Movie) {
        guard let path = movie.poster_path, let url = URL(string: "https://image.tmdb.org/t/p/w500/\(path)") else {
            return
        }

        movieImageView.sd_setImage(with: url, completed: nil)
    }
}
