//
//  ModelPath.swift
//  StartGps
//
//  Created by Phincon on 14/11/22.
//

import Foundation

class MapPath {
    
    var lat : Double?
    var lon : Double?
    var angle : Double?
    var speed: String?
    var id: String?
   
    init(lat : Double?,lon : Double?,angle : Double?, speed: String?, id: String?) {
        self.lat = lat
        self.lon = lon
        self.angle = angle
        self.speed = speed
        self.id = id
    }
}
