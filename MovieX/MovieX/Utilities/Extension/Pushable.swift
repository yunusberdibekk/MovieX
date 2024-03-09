//
//  Pushable.swift
//  MovieX
//
//  Created by Yunus Emre Berdibek on 29.02.2024.
//

import UIKit

protocol Pushable {
    func push(_ controller: UIViewController)
}

extension Pushable where Self: UIViewController {
    func push(_ controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
