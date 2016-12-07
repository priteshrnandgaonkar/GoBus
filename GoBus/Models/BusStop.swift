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

class BusStop: NSObject, Decodable {
    let name: String
    let id: String
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    required init?(json: JSON) {

        guard let name:String = ("name" <~~ json) else {
            return nil
        }
        guard let id: Int = "id" <~~ json else {
            return nil
        }
        guard  let location: CLLocationCoordinate2D = Decoder.decodeLocation(from: "location" <~~ json, key: "coordinates") else {
            return nil
        }
        self.subtitle = "busStopId" <~~ json
        self.name = name
        self.id = String(id)
        self.coordinate = location
        super.init()
    }
    
    override var description: String {
        return "name: \(name)" + "-" + "lat: \(coordinate.latitude)" + " long: \(coordinate.longitude)"
    }
}

extension BusStop: MKAnnotation {
    var title: String? {
        return name
    }
}

extension Decoder {
    static func decodeLocation(from json:JSON?, key: String) -> CLLocationCoordinate2D? {
        guard let json = json, let coordinates: [Double] = json[key] as? [Double], coordinates.count == 2 else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
    }
}
