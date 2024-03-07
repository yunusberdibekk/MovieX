//
//  MAShowCaseTableHeaderView.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import UIKit

final class MAShowCaseTableHeaderView: UICollectionViewCell {
    // MARK: - Variables

    static let identifier: String = "MAShowCaseTableHeaderView"

    // MARK: -  UI Components

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        addGradientLayer()
        preparePhotoCollectionViewCell()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func preparePhotoCollectionViewCell() {
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0),
            imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0),
            trailingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 0),
            imageView.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomAnchor, multiplier: 0)
        ])
    }

    private func addGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
}

extension MAShowCaseTableHeaderView {
    public func configure(movie: Movie?) {
        guard let movie, let path = movie.poster_path,
              let url = URL(string: "https://image.tmdb.org/t/p/w500/\(path)") else { return }

        imageView.sd_setImage(with: url, completed: nil)
    }
}
