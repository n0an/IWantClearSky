//
//  LocationsViewController.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import UIKit

// MARK: - LocationsViewControllerDelegate
protocol LocationsViewControllerDelegate: AnyObject  {
    func didSelect(city: String)
}

class LocationsViewController: UIViewController {
    // MARK: - STATIC METHODS
    public static func loadCitiesFromCache() -> [String] {
        if let locationsArray = UserDefaults.standard.stringArray(forKey: savedFavoriteLocationsArray) {
            return locationsArray
        }
        return []
    }
    
    public static func saveCitiesToCache(cities: [String]) {
        UserDefaults.standard.setValue(cities, forKey: savedFavoriteLocationsArray)
    }
    
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - PROPERTIES
    private var locations = [String]()
    public weak var delegate: LocationsViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCitiesFromCache()
    }
    
    // MARK: - PRIVATE
    private func loadCitiesFromCache() {
        let locationsArray = Self.loadCitiesFromCache()
        self.locations = locationsArray
        self.tableView.reloadData()
        
    }
    
    private func saveCitiesToCache() {
        Self.saveCitiesToCache(cities: self.locations)
    }
    
    private func getWeatherForEnteredCity(_ city: String) {
        ServerManager.shared.getCurrentWeatherFor(locationName: city) { [weak self] currentWeather in
            DispatchQueue.main.async {
                self?.locations.append(currentWeather.cityName ?? city)
                self?.saveCitiesToCache()
                self?.tableView.reloadData()
            }
        }
    }
    
    private func presentSearchAlertController(withTitle title: String?, message: String?, style: UIAlertController.Style, completion: @escaping (String) -> Void) {
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
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(search)
        ac.addAction(cancel)
        present(ac, animated: true, completion: nil)
    }
    
    
    // MARK: - ACTIONS
    @IBAction func actionSearchButtonTapped(_ sender: Any) {
        self.presentSearchAlertController(withTitle: "Enter city", message: nil, style: .alert) { [weak self] city in
            self?.getWeatherForEnteredCity(city)
        }
    }
    
    @IBAction func actionDoneBarButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
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

// MARK: - UITableViewDelegate
extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var selectedCity = self.locations[indexPath.row]
        self.delegate?.didSelect(city: selectedCity)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.locations.remove(at: indexPath.row)
        self.saveCitiesToCache()
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
}
