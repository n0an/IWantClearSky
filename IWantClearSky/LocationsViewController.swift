//
//  LocationsViewController.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import UIKit

protocol LocationsViewControllerDelegate: AnyObject  {
    func didSelect(city: String)
}

class LocationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var locations = [String]()
    
    weak var delegate: LocationsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCities()
    }
    
    func loadCities() {
        if let loadedArray = UserDefaults.standard.stringArray(forKey: savedFavoriteLocationsArray) {
            self.locations = loadedArray
            self.tableView.reloadData()
        }
    }
    
    func saveCities() {
        UserDefaults.standard.setValue(self.locations, forKey: savedFavoriteLocationsArray)
    }
    
    
    @IBAction func actionSearchButtonTapped(_ sender: Any) {
        self.presentSearchAlertController(withTitle: "Enter city", message: nil, style: .alert) { [weak self] city in
            self?.getWeatherForEnteredCity(city)
        }
    }
    
    func getWeatherForEnteredCity(_ city: String) {
        let city = city.split(separator: " ").joined(separator: "%20")
        ServerManager.shared.getCurrentWeatherFor(locationName: city) { [weak self] currentWeather in
            self?.locations.append(city)
            self?.saveCities()
            self?.tableView.reloadData()
        }
    }
    
    
    func presentSearchAlertController(withTitle title: String?, message: String?, style: UIAlertController.Style, completion: @escaping (String) -> Void) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: style)
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
//            if cityName != "" {
//                let city = cityName.split(separator: " ").joined(separator: "%20")
//                completion(city)
//            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(search)
        ac.addAction(cancel)
        present(ac, animated: true, completion: nil)
    }
    
    
    @IBAction func actionDoneBarButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension LocationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        cell.configureCell(with: self.locations[indexPath.row])
        return cell
    }
}

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let city = self.locations[indexPath.row].split(separator: " ").joined(separator: "%20")
        self.delegate?.didSelect(city: city)
        self.dismiss(animated: true, completion: nil)
    }
}
