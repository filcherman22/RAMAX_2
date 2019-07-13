//
//  OpenWeatherMapParser.swift
//  RAMAX_2
//
//  Created by Филипп on 11.07.2019.
//  Copyright © 2019 Филипп. All rights reserved.
//

import UIKit

class OpenWeatherMapParser {
    
    var temp: Float
    var icon: UIImage?
    var time: Double
    var lon: Double
    var lat: Double
    
    init(data: NSDictionary, lon: Double, lat: Double){
        
        self.lon = lon
        self.lat = lat
        let main = data["main"] as! NSDictionary
        let temp = main["temp"] as! NSNumber
        self.temp = Float(truncating: temp) - 273.15
        self.time = Date().timeIntervalSince1970
        let weather = data["weather"] as! [NSDictionary]
        let iconStr = weather[0]["icon"] as! String
        self.icon = getWeatherIcon(icon: iconStr)
    }
    
    private func getWeatherIcon(icon: String) -> UIImage{
        let image = UIImage(named: icon)
        return image!
    }
}
