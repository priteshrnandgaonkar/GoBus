//
//  Bus.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/7/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import Foundation
import MapKit
import Gloss

class Bus: NSObject, Decodable {
    let id: String
    let busId: String
    let name: String
    let number: String
    let busDescription: String
    let destination: String
    let direction: String
    var route: [CLLocationCoordinate2D]?
    
    var polyLine: MKPolyline? {
        guard let uRoute = route else {
            return nil
        }
        return MKPolyline(coordinates:uRoute, count: uRoute.count)
    }
    
    required init?(json: JSON) {
        guard let id: Int = "id" <~~ json else {
            return nil
        }
        guard let busId: String = "busId" <~~ json else {
            return nil
        }
        guard let name:String = ("name" <~~ json) else {
            return nil
        }
        guard let number: String = "number" <~~ json else {
            return nil
        }
        guard let description: String = "description" <~~ json else {
            return nil
        }
        guard let destination: String = "destination" <~~ json else {
            return nil
        }
        guard let direction: String = "direction" <~~ json else {
            return nil
        }
        
        self.id = String(id)
        self.busId = busId
        self.name = name
        self.number = number
        self.busDescription = description
        self.destination = destination
        self.direction = direction
        self.route = nil
        super.init()
    }
}
