//
//  CurrentWeather.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 06.02.2021.
//

import Foundation

struct CurrentWeather: WeatherItem {
    var cityName: String?
    var currentTemp: Double
    var description: String?
    var iconId: String?
    var code: Int
    var isNight: Bool
}
