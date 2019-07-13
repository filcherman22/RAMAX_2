//
//  Coorditates.swift
//  RAMAX_2
//
//  Created by Филипп on 11.07.2019.
//  Copyright © 2019 Филипп. All rights reserved.
//

import Foundation

struct CoordStruct {
    let lat: Double
    let lon: Double
    init(x: Double, y: Double) {
        self.lat = x
        self.lon = y
    }
}

class Coordinates {
    
    func getArrCoordinates(lat: Double, lon: Double) -> [CoordStruct]{
        var arr: [CoordStruct] = []
        let nStepX = Int(170.0 / lat)
        let nStepY = Int(360.0 / lon)
        for i in 0...nStepY {
            for j in 0...nStepX{
                let data = CoordStruct(x: -80.0 + Double(j) * lat, y: -180 + Double(i) * lon)
                arr.append(data)
            }
        }
        return arr
    }
}
