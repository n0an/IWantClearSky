//
//  WeatherItem.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 07.02.2021.
//

import Foundation

protocol WeatherItem: Codable {
    func getTemperatureStr(temp: Double) -> String
}

extension WeatherItem {
    func getTemperatureStr(temp: Double) -> String {
        let temp = Int(temp)
        var tempStr = "\(temp)º"
        if temp > 0 {
            tempStr = "+\(tempStr)"
        }
        return tempStr
    }
}
