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
        let city = locationName.split(separator: " ").joined(separator: "%20")
        ServerManager.shared.getCurrentWeatherFor(locationName: city) { currentWeather in
            self.tempLabel.text = currentWeather.prepareTemperatureStr(temp: currentWeather.currentTemp)
        }
    }
}
