//
//  ForecastItem.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import Foundation

struct ForecastItem: WeatherItem {
    var weatherDescription: String?
    var maxTemp: Double
    var minTemp: Double
    var date: Date
    var iconId: String?
}

protocol WeatherItem: Codable {
    func prepareTemperatureStr(temp: Double) -> String
}

extension WeatherItem {
    func prepareTemperatureStr(temp: Double) -> String {
        let temp = Int(temp)
        var tempStr = "\(temp)º"
        if temp > 0 {
            tempStr = "+\(tempStr)"
        }
        return tempStr
    }
}
