//
//  ForecastViewController.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import UIKit

class ForecastViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var forecastItems = [ForecastItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.forecastItems = []
        self.tableView.reloadData()
        self.getForecastItemsFromCache()
        self.getForecastItemsFromServer()
    }
    
    func getForecastItemsFromCache() {
        guard let data = UserDefaults.standard.object(forKey: savedForecast) as? Data else {
            return
        }
        if let forecastItems = try? JSONDecoder().decode([ForecastItem].self, from: data) {
            self.forecastItems = forecastItems
            self.tableView.reloadData()
        }
    }
    
    func getForecastItemsFromServer() {
        ServerManager.shared.getForecastForLastSearched { forecastItems in
            self.forecastItems = forecastItems
            self.tableView.reloadData()
        }
    }
}

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
