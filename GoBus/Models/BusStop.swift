//
//  BusStop.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/5/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import Foundation
//import Banana
import Gloss


struct Location: Decodable {
    let latitude: Double
    let longitude: Double
    
    init?(json: JSON) {
        guard let tuple = Decoder.decodeLocation(from: json, key: "coordinates") else {
            return nil
        }
        (latitude, longitude) = tuple
    }
}

extension Decoder {
    static func decodeLocation(from json:JSON, key: String) -> (Double, Double)? {
        guard let coordinates: [Double] = json[key] as? [Double], coordinates.count == 2 else {
            return nil
        }
        return (coordinates[0], coordinates[1])
    }
}

struct BusStop: Decodable {
    let name: String?
    let id: String?
    let location: Location?
    
    init?(json: JSON) {

        guard let name:String = ("name" <~~ json) else {
            return nil
        }
        guard let id: String = "busStopId" <~~ json else {
            return nil
        }
        guard  let location: Location = "location" <~~ json else {
            return nil
        }
        
        self.name = name
        self.id = id
        self.location = location
    }
}
