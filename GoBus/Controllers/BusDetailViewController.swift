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
import SVProgressHUD

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
        
        if let _ = bus.route {
            updateMapWithRoutes()
        }
        else {
            fetchAndupdateViewWith(routeFor: bus)
        }
    }
    
    func fetchAndupdateViewWith(routeFor bus: Bus) {
        
        SVProgressHUD.show(withStatus: "Fetching Route...")
        
        fetchRoute(forBus: bus, with: {[weak self, weak bus] (result: Result<[CLLocationCoordinate2D], NetworkError>) in
            
            SVProgressHUD.dismiss()
            guard let weakSelf = self, let weakBus = bus else {
                return
            }
            switch result {
            case .success(let route):
                if route.count <= 0 {
                    let alertController = Utility.getAlertViewController(withTitle: "GoBus", message: "No route information is available, Pls try other bus", buttonTitle: "Ok")
                    weakSelf.present(alertController, animated: true, completion: nil)
                }
                weakSelf.bus.route = route
                weakSelf.updateMapWithRoutes()
            case .failure(let error):
                weakSelf.handle(error: error, withRetryBlock: { 
                    weakSelf.fetchAndupdateViewWith(routeFor: weakBus)
                })
            }
        })
    }
    
    func updateMapWithRoutes() {
        
        guard let polyLine = bus.polyLine else {
            return
        }
        mapView.add(polyLine)
        mapView.setVisibleMapRect(polyLine.boundingMapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
    }
    
    
    func fetchRoute(forBus bus: Bus, with completion:@escaping (Result<[CLLocationCoordinate2D], NetworkError>) -> ()) {
        
        let url = Constants.baseUrl + Constants.fetchBusRouteApiPath + "/\(bus.id)/route"
        
        NetworkUtility.getJSON(url: url, withCompletion: { (result: Result<JSON, NetworkError>) in
            switch result {
            case .success(let json):
            guard let points: [[Double]] = json["points"] as? [[Double]] else {
                    completion(Result.failure(NetworkError.parsingError))
                    return
                }
                let routes =  points.map({ CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) })
                completion(Result.success(routes))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
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

extension BusDetailViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay);
        pr.strokeColor = UIColor.black
        pr.lineWidth = 5;
        return pr;
    }
    
}
