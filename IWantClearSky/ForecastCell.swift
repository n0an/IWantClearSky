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
        
        self.maxTempLabel.text = forecastItem.prepareTemperatureStr(temp: forecastItem.maxTemp)
        self.minTempLabel.text = forecastItem.prepareTemperatureStr(temp: forecastItem.minTemp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayStr = dateFormatter.string(from: forecastItem.date)
        self.dayLabel.text = dayStr
        
        if let iconId = forecastItem.iconId {
            ServerManager.shared.fetchWeatherIconFor(iconId: iconId) { data in
                self.weatherImageView.image = UIImage(data: data)
            }
        }
        
        
        
//        http://openweathermap.org/img/wn/10d@2x.png
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
