//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 27.02.2024.
//

import UIKit

protocol HomeViewControllerProtocol: AnyObject {
    var frame: CGRect { get }

    func prepareViewController()
    func prepareTableView()
}

final class HomeViewController: UIViewController {
    private lazy var viewModel: HomeViewModelProtocol = HomeViewModel()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            MovieTableViewCell.self,
            forCellReuseIdentifier: MovieTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewDidLoad()
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    var frame: CGRect {
        view.frame
    }

    func prepareViewController() {
        view.backgroundColor = .secondarySystemBackground
    }

    func prepareTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.tableHeaderView = MovieTableHeaderView(
            frame: .init(x: .zero, y: .zero, width: view.frame.width, height: view.frame.height * 0.70))
        tableView.delegate = self
        tableView.dataSource = self

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

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else { fatalError() }

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

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.heightForRowAt()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        viewModel.heightForHeaderInSection()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.titleForHeaderInSection(section)
    }
}
