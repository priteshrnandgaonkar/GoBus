//
//  Utility.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/6/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Alamofire

enum NetworkError: Error {
    case noData
    case noResponse
    case statusCode(Int)
    case parsingError
    case unKnowError
    
    init?(with dataResponse: DataResponse<Any>) {
        guard let _ = dataResponse.data else {
            self = .noData
            return
        }
        guard let response = dataResponse.response else {
            self = .noResponse
            return
        }
        
        let statusCode = response.statusCode
        guard statusCode == 200 else {
            self = .statusCode(statusCode)
            return
        }
        return nil
    }
}

struct Utility {
    static func showAlertViewController(withTitle title: String, message: String?, buttonTitle: String, cancelButtonTitle: String, buttonAction: @escaping (()->())) -> UIAlertController {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: buttonTitle, style: .default) { action in buttonAction() }
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .destructive)
        
        controller.addAction(cancelAction)
        controller.addAction(action)

        return controller
    }
}

extension UIStoryboard {
    
    static var mainStoryBoard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}

extension UIViewController {
    
    static func instantiateViewController<T: UIViewController>(with identifier: String) -> T {
        return UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: identifier) as! T
    }
}
