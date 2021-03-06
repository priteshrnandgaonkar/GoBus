//
//  BusListViewController.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/7/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
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
        
        SVProgressHUD.show(withStatus: "Fetching Buses...")
        
        let url = Constants.baseUrl + Constants.fetchBusesApiPath + "/\(busStop.id)/buses"
        NetworkUtility.getJSONArray(url: url, withCompletion: ({ [weak self, weak busStop]
        (result: Result<[JSON], NetworkError>) in

            SVProgressHUD.dismiss()
            
            guard let weakSelf = self else {
                return
            }
            
            switch result {
            case .success(let array):
                guard let buses = [Bus].from(jsonArray: array) else {
                    return
                }
                if buses.count <= 0 {
                    let alertController = Utility.getAlertViewController(withTitle: "GoBus", message: "There are no buses passing from the selected bus stop, Please try using different bus stops", buttonTitle: "Ok")
                    weakSelf.present(alertController, animated: true, completion: nil)
                }
                else {
                    weakSelf.updateTable(with: buses)
                }
            case .failure(let error):
                guard let weakBusStop = busStop else {
                    return
                }
                weakSelf.handle(error: error, withRetryBlock: { weakSelf.fetchBuses(from: weakBusStop) })
            }

        }))
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
