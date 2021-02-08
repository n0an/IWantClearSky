//
//  LocationCell.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import UIKit

class LocationCell: UITableViewCell {
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    public func configureCell(with locationName: String) {
        self.locationNameLabel.text = locationName.capitalized
        
        ServerManager.shared.getCurrentWeatherFor(locationName: locationName,
                                                  needNotify: false) { [weak self] currentWeather in
            DispatchQueue.main.async {
                if let currentTemp = currentWeather.currentTemp {
                    self?.tempLabel.text = currentWeather.getTemperatureStr(temp: currentTemp)
                }
            }
        }
    }
}
