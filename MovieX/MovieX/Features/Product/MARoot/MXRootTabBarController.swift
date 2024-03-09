//
//  MXRootTabBarController.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 28.02.2024.
//

import UIKit

final class MXRootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .label
        setUpTabBar()
    }

    private func setUpTabBar() {
        let showCaseVC = createNavigationController(
            vc: MXShowCaseViewController(),
            title: "Show Case",
            image: .house,
            prefersLargeTitles: false,
            tag: 0)
        let discoverVC = createNavigationController(
            vc: MXDiscoverViewController(),
            title: "Discover",
            image: .magnifyingglass,
            prefersLargeTitles: true,
            tag: 1)
        let comingSoonNC = createNavigationController(
            vc: MXComingSoonViewController(),
            title: "Coming Soon",
            image: .play_circle,
            prefersLargeTitles: true,
            tag: 2)
        let downloadsNC = createNavigationController(
            vc: MXDownloadsViewController(),
            title: "Downloads",
            image: .arrow_down_to_line,
            prefersLargeTitles: true,
            tag: 3)

        setViewControllers([
            showCaseVC,
            discoverVC,
            comingSoonNC,
            downloadsNC,
        ], animated: true)
    }

    private func createNavigationController(vc: UIViewController, title: String, image: SFSymbols, prefersLargeTitles: Bool, tag: Int) -> UINavigationController {
        let navVC = UINavigationController(rootViewController: vc)

        navVC.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image.rawValue),
            tag: tag)
        navVC.navigationItem.largeTitleDisplayMode = !prefersLargeTitles ? .inline : .automatic
        navVC.navigationBar.prefersLargeTitles = prefersLargeTitles ? true : false

        return navVC
    }
}
