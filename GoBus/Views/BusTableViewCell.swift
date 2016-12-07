//
//  BusTableViewCell.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/7/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import Foundation
import UIKit

class BusTableViewCell: UITableViewCell {
    static let reuseIdentifier = "BusTableViewCell"
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var direction: UILabel!
    
    func populateCell(from bus: Bus) {
        name.text = bus.name
        destination.text = bus.destination
        direction.text = "Type: " + bus.direction
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = false
        self.layer.shadowColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        
        layer.cornerRadius = 20
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 4.0
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
