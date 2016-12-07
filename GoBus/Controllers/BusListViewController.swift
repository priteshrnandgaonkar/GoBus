//
//  BusListViewController.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/7/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import Foundation
import UIKit
import AlamofireGloss
import Alamofire

class BusListViewController: UIViewController {
    
    var busStop: BusStop!
    var buses = [Bus]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBuses(from: busStop)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        title = "Buses"
    }
    
    func fetchBuses(from busStop: BusStop){
        
        Alamofire.request("http://54.255.135.90/busservice/api/v1/bus-stops/\(busStop.id)/buses").responseArray(Bus.self) { [weak self](response) in
            
            guard let weakSelf = self else {
                return
            }
            
            switch response.result {
            case .success(let buses):
                weakSelf.updateTable(with: buses)
            case .failure(let error):
//                if let error = error as? AFError {
//                }
                print(error)
            }
        }
    }
    
    func updateTable(with buses: [Bus]) {
        self.buses = buses
        self.tableView.reloadData()
    }
}

extension BusListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell: BusTableViewCell = tableView.dequeueReusableCell(withIdentifier: BusTableViewCell.reuseIdentifier) as? BusTableViewCell else {
            fatalError("Dequeud cell is not of type BusTableViewCell")
        }
        
        cell.populateCell(from: buses[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc: BusDetailViewController = UIViewController.instantiateViewController(with: "BusDetailViewController")
        vc.bus = buses[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)        
    }
    
}
