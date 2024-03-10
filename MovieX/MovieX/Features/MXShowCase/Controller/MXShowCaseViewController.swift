//
//  MXShowCaseViewController.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 27.02.2024.
//

import UIKit

protocol MXShowCaseViewControllerProtocol: AnyObject, Pushable, Alertable {
    var movieTableHeaderView: MXShowCaseTableHeaderView? { get set }
    var frame: CGRect { get }

    func prepareViewController()
    func prepareTableView()
}

final class MXShowCaseViewController: UIViewController {
    private lazy var viewModel: MXShowCaseViewModelProtocol = MXShowCaseViewModel()

    // MARK: - UI Components

    var movieTableHeaderView: MXShowCaseTableHeaderView?

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            MXShowCaseTableViewCell.self,
            forCellReuseIdentifier: MXShowCaseTableViewCell.identifier)
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

extension MXShowCaseViewController: MXShowCaseViewControllerProtocol {
    var frame: CGRect {
        view.frame
    }

    func prepareViewController() {
        view.backgroundColor = .systemBackground
    }

    func prepareTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        movieTableHeaderView = MXShowCaseTableHeaderView(
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

extension MXShowCaseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MXShowCaseTableViewCell.identifier, for: indexPath) as? MXShowCaseTableViewCell else { fatalError() }

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

extension MXShowCaseViewController: UITableViewDelegate {
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

extension MXShowCaseViewController: MXShowCaseTableViewCellProtocol {
    func didSelectRow(_ movie: Movie) {
        viewModel.didSelectRowAt(movie)
    }

    func didTapDownloadAction(_ movie: Movie?) {
        viewModel.didSelectContextMenuConfiguration(movie)
    }
}
