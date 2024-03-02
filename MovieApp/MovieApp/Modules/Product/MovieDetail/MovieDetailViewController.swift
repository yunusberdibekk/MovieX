//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import UIKit
import WebKit

protocol MovieDetailViewControllerProtocol: Alertable, AnyObject {
    var webView: WKWebView { get }
    var titleLabel: UILabel { get }
    var overviewLabel: UILabel { get }

    func prepareNavigationBar()
    func prepareWebView()
    func prepareLabels()
    func updateBookmarkImage(_ sfImage: SFSymbols)
}

final class MovieDetailViewController: UIViewController {
    private var viewModel: MovieDetailViewModelProtocol

    let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .red
        return webView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    init(movie: Movie, movieDetail: MovieDetail) {
        viewModel = MovieDetailViewModel(
            movie: movie,
            movieDetail: movieDetail)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        viewModel.view = self
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
}

extension MovieDetailViewController: MovieDetailViewControllerProtocol {
    func prepareWebView() {
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }

    func prepareLabels() {
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalToSystemSpacingBelow: webView.bottomAnchor,
                multiplier: 2),
            titleLabel.leadingAnchor.constraint(
                equalToSystemSpacingAfter: view.leadingAnchor,
                multiplier: 2),
            view.trailingAnchor.constraint(
                equalToSystemSpacingAfter: titleLabel.trailingAnchor,
                multiplier: 1),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),

            overviewLabel.topAnchor.constraint(
                equalToSystemSpacingBelow: titleLabel.bottomAnchor,
                multiplier: 0),
            overviewLabel.leadingAnchor.constraint(
                equalToSystemSpacingAfter: view.leadingAnchor,
                multiplier: 2),
            view.trailingAnchor.constraint(
                equalToSystemSpacingAfter: overviewLabel.trailingAnchor,
                multiplier: 2),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalToSystemSpacingBelow: overviewLabel.bottomAnchor,
                multiplier: 2)
        ])
    }

    func prepareNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: SFSymbols.bookmark.rawValue),
            style: .done,
            target: self,
            action: #selector(didTapBookmarkButton))
    }

    func updateBookmarkImage(_ sfImage: SFSymbols) {
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: sfImage.rawValue)
    }

    @objc func didTapBookmarkButton() {
        viewModel.didTapBookmarkButton()
    }
}
