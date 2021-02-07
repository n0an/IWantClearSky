//
//  ForecastCell.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import UIKit

class ForecastCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    public func configureCell(with forecastItem: ForecastItem) {
        self.weatherDescriptionLabel.text = forecastItem.weatherDescription
        if let maxTemp = forecastItem.maxTemp {
            self.maxTempLabel.text = forecastItem.getTemperatureStr(temp: maxTemp)
        }
        if let minTemp = forecastItem.minTemp {
            self.minTempLabel.text = forecastItem.getTemperatureStr(temp: minTemp)
        }
        if let date = forecastItem.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let dayStr = dateFormatter.string(from: date)
            self.dayLabel.text = dayStr
        }
        if let iconId = forecastItem.iconId {
            ServerManager.shared.fetchWeatherIconFor(iconId: iconId) { data in
                DispatchQueue.main.async {                
                    self.weatherImageView.image = UIImage(data: data)
                }
            }
        }
    }
}
