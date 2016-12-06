//
//  ViewController.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/5/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import UIKit
import AlamofireGloss
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Alamofire.request("http://54.255.135.90/busservice/api/v1/bus-stops/radius?lat=24.44072&lon=54.44392&radius=500").responseArray(BusStop.self) { (response) in
            switch response.result {
            case .success(let people):
                print("Found Busstop: \(people)")
            case .failure(let error):
                print("Error'd: \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

