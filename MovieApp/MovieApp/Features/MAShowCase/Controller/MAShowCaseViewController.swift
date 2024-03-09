//
//  MAShowCaseViewController.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 27.02.2024.
//

import UIKit

protocol MAShowCaseViewControllerProtocol: AnyObject, Pushable, Alertable {
    // MARK: - Variables

    var movieTableHeaderView: MAShowCaseTableHeaderView? { get set }
    var frame: CGRect { get }

    // MARK: - Functions

    func prepareViewController()
    func prepareTableView()
}

final class MAShowCaseViewController: UIViewController {
    // MARK: - Variables

    private lazy var viewModel: MAShowCaseViewModelProtocol = MAShowCaseViewModel()

    // MARK: - UI Components

    var movieTableHeaderView: MAShowCaseTableHeaderView?

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            MAShowCaseTableViewCell.self,
            forCellReuseIdentifier: MAShowCaseTableViewCell.identifier)
        return tableView
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

// MARK: - Controller + MAShowCaseViewControllerDelegate

extension MAShowCaseViewController: MAShowCaseViewControllerProtocol {
    var frame: CGRect {
        view.frame
    }

    func prepareViewController() {
        title = "Show Case"
        view.backgroundColor = .secondarySystemBackground
    }

    func prepareTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        tableView.dataSource = self

        movieTableHeaderView = MAShowCaseTableHeaderView(
            frame: .init(x: .zero, y: .zero, width: view.frame.width, height: view.frame.height * 0.70))
        tableView.tableHeaderView = movieTableHeaderView
        viewModel.viewForHeader()

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

// MARK: - Controller + UITableViewDataSource

extension MAShowCaseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MAShowCaseTableViewCell.identifier, for: indexPath) as? MAShowCaseTableViewCell else { fatalError() }

        cell.delegate = self
        viewModel.cellForRowAt(indexPath.section) { result in
            switch result {
            case .success(let response):
                cell.configure(with: response.results)
            case .failure(let error):
                print(error.description)
            }
        }

        return cell
    }
}

// MARK: - Controller + UITableViewDelegate

extension MAShowCaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.heightForRowAt()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        viewModel.heightForRowInSection()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.titleForHeaderInSection(section)
    }
}

// MARK: - Controller + HomeMovieTableViewCellProtocol

extension MAShowCaseViewController: MAShowCaseTableViewCellProtocol {
    func didSelectRow(_ movie: Movie) {
        viewModel.didSelectRowAt(movie)
    }

    func didTapDownloadAction(_ movie: Movie?) {
        viewModel.didSelectContextMenuConfiguration(movie)
    }
}
