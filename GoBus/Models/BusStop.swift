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
import MapKit

//
//struct Location: Decodable {
//    let latitude: Double
//    let longitude: Double
//    
//    init?(json: JSON) {
//        guard let tuple = Decoder.decodeLocation(from: json, key: "coordinates") else {
//            return nil
//        }
//        (latitude, longitude) = tuple
//    }
//}
//
//extension Decoder {
//    static func decodeLocation(from json:JSON, key: String) -> (Double, Double)? {
//        guard let coordinates: [Double] = json[key] as? [Double], coordinates.count == 2 else {
//            return nil
//        }
//        return (coordinates[0], coordinates[1])
//    }
//}

class BusStop: NSObject, MKAnnotation, Decodable {
    let name: String
    let id: String
    let coordinate: CLLocationCoordinate2D
    
    required init?(json: JSON) {

        guard let name:String = ("name" <~~ json) else {
            return nil
        }
        guard let id: String = "busStopId" <~~ json else {
            return nil
        }
        guard  let location: CLLocationCoordinate2D = Decoder.decodeLocation(from: "location" <~~ json, key: "coordinates") else {
            return nil
        }
        
        self.name = name
        self.id = id
        self.coordinate = location
    }
    
    override var description: String {
        return "name: \(name)" + "-" + "lat: \(coordinate.latitude)" + " long: \(coordinate.longitude)"
    }
}

extension Decoder {
    static func decodeLocation(from json:JSON?, key: String) -> CLLocationCoordinate2D? {
        guard let json = json, let coordinates: [Double] = json[key] as? [Double], coordinates.count == 2 else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: coordinates[0], longitude: coordinates[1])
    }
}
