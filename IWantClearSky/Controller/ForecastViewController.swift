//
//  ForecastViewController.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import UIKit

class ForecastViewController: UIViewController {
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - PROPERTIES
    private var forecastItems = [ForecastItem]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.currentWeatherUpdated),
                                               name: NSNotification.Name(NotificationCurrentWeatherDidLoad),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getForecastItemsFromCache()
        self.getForecastItemsFromServer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - PRIVATE
    @objc private func currentWeatherUpdated() {
        self.getForecastItemsFromServer()
    }
    
    private func getForecastItemsFromCache() {
        self.forecastItems = ForecastItem.loadForecastFromCache()
        self.tableView.reloadData()
    }
    
    private func getForecastItemsFromServer() {
        ServerManager.shared.getForecastForLastSearched { [weak self] forecastItems in
            DispatchQueue.main.async {
                self?.forecastItems = forecastItems
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ForecastViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forecastItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell") as! ForecastCell
        cell.configureCell(with: self.forecastItems[indexPath.row])
        return cell
    }
}
