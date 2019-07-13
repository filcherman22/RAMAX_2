//
//  OpenWeatherMap.swift
//  RAMAX_2
//
//  Created by Филипп on 11.07.2019.
//  Copyright © 2019 Филипп. All rights reserved.
//

import Foundation

struct WeatherStruct {
    let temp: Float
    let main: String
    init(temp: Float, main: String) {
        self.temp = temp
        self.main = main
    }
}

class OpenWeatherMap {
    
    var session: URLSession
    
    init() {
        self.session = URLSession.shared
    }
    
    func getOpenWeatherMapParser(lat: Double, lon: Double,_ callback: @escaping (OpenWeatherMapParser?) -> Void){
        
        let url = self.getUrl(lat: lat, lon: lon)
        let stringUrl = URL(string: url)
        let task = self.session.downloadTask(with: stringUrl!){location, response, error in
            do{
                let weatherData = try Data(contentsOf: stringUrl!)
                let weatherJson = try JSONSerialization.jsonObject(with: weatherData, options: []) as! NSDictionary
                let dataObject = OpenWeatherMapParser(data: weatherJson, lon: lon, lat: lat)
                
                if error == nil{
                    callback(dataObject)
                }
                else{
                    callback(nil)
                }
            }
            catch{
                print("error", error)
                callback(nil)
            }
        }
        task.resume()
    }
    
    private func getUrl(lat: Double, lon: Double) -> String{
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=" + String(lat) + "&lon=" + String(lon) + "&appid=118a9930fc7071beb536d9de7a5d1380"
        return url
    }
    
}
