//
//  Alertable.swift
//  MovieApp
//
//  Created by Yunus Emre Berdibek on 2.03.2024.
//

import UIKit

protocol Alertable {
    func alert(title: String, message: String, actionTitle: String)
}

extension Alertable where Self: UIViewController {
    func alert(title: String, message: String, actionTitle: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: actionTitle,
            style: .default)

        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}
