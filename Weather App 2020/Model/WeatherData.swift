//
//  WeatherData.swift
//  Weather App 2020
//
//  Created by Miguel Planckensteiner on 20.07.20.
//  Copyright © 2020 Miguel Planckensteiner. All rights reserved.
//

import Foundation


struct WeatherData: Decodable {

    let name: String
    let main: Main
    let weather: [Weather]
    
    
    var model: WeatherModel {
        return WeatherModel(countryName: name,
                            temp: main.temp.toInt(),
                            conditionId: weather.first?.id ?? 0,
                            conditionDescription: weather.first?.description ?? "")
    }
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {

    let id: Int
    let main: String
    let description: String
}


struct WeatherModel {

    let countryName: String
    let temp: Int
    let conditionId: Int
    let conditionDescription: String


    var conditionImage: String {

        switch conditionId {
        case 200...299:
            return "imThunderstorm"
        case 300...399:
            return "imDrizzle"
        case 500...599:
            return "imRain"
        case 600...699:
            return "imSnow"
        case 700...799:
            return "imAtmosphere"
        case 800:
            return "imClear"
        default:
            return "imClouds"

        }
    }

    var conditionBackgroundImage: String {

        switch conditionId {
        case 200...299:
            return "thunderstorm"
        case 300...399:
            return "cloudDrizzle"
        case 500...599:
            return "heavyRain"
        case 600...699:
            return "snow"
        case 700...799:
            return "clouds"
        case 800:
            return "sunnyClear"
        default:
            return "clouds"

        }
    }

}
