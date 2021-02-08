//
//  UIViewController+searchCity.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 08.02.2021.
//

import UIKit

protocol Alertable {}

extension Alertable where Self: UIViewController {
    func presentSearchCityAlertController(withTitle title: String?,
                                          message: String?,
                                          style: UIAlertController.Style,
                                          completion: @escaping (String) -> Void) {
        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: style)
        ac.addTextField { tf in
            let cities = ["Moscow",
                          "London",
                          "Amsterdam",
                          "New York",
                          "San Francisco",
                          "Mumbai"]
            tf.placeholder = cities.randomElement()
        }
        let search = UIAlertAction(title: "Search", style: .default) { action in
            let textField = ac.textFields?.first
            guard let cityName = textField?.text else { return }
            completion(cityName)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(search)
        ac.addAction(cancel)
        present(ac, animated: true, completion: nil)
    }
}
