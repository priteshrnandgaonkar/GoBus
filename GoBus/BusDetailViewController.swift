//
//  BusDetailViewController.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/7/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Alamofire
import Gloss

class BusDetailViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var direction: UILabel!
    @IBOutlet weak var busId: UILabel!
    @IBOutlet weak var busDecription: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var bus: Bus!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bus Detail"
        populateView(with: bus)
        updateViewWith(routeFor: bus)
    }
    
    func updateViewWith(routeFor bus: Bus) {
        fetchRoute(forBus: bus, with: {[weak self] (result) in
            
            guard let weakSelf = self else {
                return
            }
            
            switch result {
            case .success(_): break
//                weakSelf.updateMapWithRoutes()
            case .failure(_): break
            }
        })
    }
    
//    func updateMapWithRoutes() {
//        var annotations = [MKAnnotation]()
//        for coordinate in
//    }
//    
    
    func fetchRoute(forBus bus: Bus, with completion:@escaping (Result<[CLLocationCoordinate2D], NetworkError>) -> ()) {
        Alamofire.request("http://54.255.135.90/busservice/api/v1/buses/\(bus.id)/route").responseJSON {[weak self] (dataResponse: DataResponse<Any>) in
            
            guard let weakSelf = self else {
                completion(Result.failure(.unKnowError))
                return
            }

            if let error = NetworkError.init(with: dataResponse) {
                completion(Result.failure(error))
            }
            
            do {
                let arrayJSON = try JSONSerialization.jsonObject(with: dataResponse.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                guard let  json = arrayJSON as? JSON, let points: [[Double]] = json["points"] as? [[Double]] else {
                    return //FIXME
                }
                
                weakSelf.bus.route =  points.map({ CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) })
            }
            catch {
                
            }
        }

    }
    
    func populateView(with bus: Bus) {
        name.text = bus.name
        destination.text = bus.destination
        busDecription.text = bus.busDescription
        busId.text = bus.busId
        direction.text = bus.direction
        number.text = bus.number
    }
}
