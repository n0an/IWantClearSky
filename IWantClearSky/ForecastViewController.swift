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
        
        ServerManager.shared.getForecastForLastWeatherLocation { forecastItems in
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
