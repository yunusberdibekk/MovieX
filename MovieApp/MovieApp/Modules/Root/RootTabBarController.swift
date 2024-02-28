//
//  RootViewController.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import UIKit

final class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .label
        setUpTabBar()
    }

    private func setUpTabBar() {
        let homeNC = createController(
            vc: HomeViewController(),
            title: "Home",
            image: .house,
            tag: 0)
        let comingSoonNC = createNavigationController(
            vc: ComingSoonViewController(),
            title: "Coming Soon",
            image: .play_circle,
            tag: 1)
        let searchesNC = createNavigationController(
            vc: TopSearchesViewController(),
            title: "Top Searches",
            image: .magnifyingglass,
            tag: 2)
        let downloadsNC = createNavigationController(
            vc: DownloadsViewController(),
            title: "Downloads",
            image: .arrow_down_to_line,
            tag: 3)

        setViewControllers([
            homeNC,
            comingSoonNC,
            searchesNC,
            downloadsNC,
        ], animated: true)
    }

    private func createNavigationController(vc: UIViewController, title: String, image: SFSymbols, tag: Int) -> UINavigationController {
        let navVC = UINavigationController(rootViewController: vc)

        navVC.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image.rawValue),
            tag: tag)
        navVC.navigationItem.largeTitleDisplayMode = .automatic
        navVC.navigationBar.prefersLargeTitles = true

        return navVC
    }

    private func createController(vc: UIViewController, title: String, image: SFSymbols, tag: Int) -> UIViewController {
        vc.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image.rawValue),
            tag: tag)

        return vc
    }
}
