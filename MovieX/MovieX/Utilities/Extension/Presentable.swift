//
//  Presentable.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 2.03.2024.
//

import UIKit

protocol Presentable {
    func present(_ controller: UIViewController)
}

extension Presentable where Self: UIViewController {
    func present(_ controller: UIViewController) {
        present(controller, animated: true)
    }
}
