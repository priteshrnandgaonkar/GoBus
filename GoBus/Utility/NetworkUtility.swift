//
//  NetworkUtility.swift
//  GoBus
//
//  Created by Pritesh Nandgaonkar on 12/7/16.
//  Copyright © 2016 Pritesh Nandgaonkar. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkError: Error,ErrorMessage {
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
    
    var errorMessage: String {
        var message = ""
        switch self {
        case .noData:
            message = "No Data received from server, Check your Internet"
        case .noResponse:
            message = "No Response received from server, Check your Internet"
        case .parsingError:
            message = "Parsing error, Try after sometime"
        case .statusCode(let code):
            message = "Server error: \(code), Try after sometime"
        case .unKnowError:
            message = "Internal Error, Try after sometime"
        }
        return message
    }
}

typealias JSON = [String: Any]

struct NetworkUtility {
    
    static func getJSON(url: String, withCompletion completion: @escaping (Result<JSON, NetworkError>) -> ()) {
        
        Alamofire.request(url).responseJSON(completionHandler: { (dataResponse: DataResponse<Any>) in
            
            if let error = NetworkError.init(with: dataResponse) {
                completion(Result.failure(error))
                return
            }
            do {
                let dict = try JSONSerialization.jsonObject(with: dataResponse.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                guard let json = dict as? JSON else {
                    completion(Result.failure(.parsingError))
                    return
                }
                completion(Result.success(json))
            }
            catch {
                completion(Result.failure(.parsingError))
            }
        })
    }
    
    static func getJSONArray(url: String, withCompletion completion: @escaping (Result<[JSON], NetworkError>) -> ()) {
        
        Alamofire.request(url, method: .get, parameters: nil).responseJSON { (dataResponse: DataResponse<Any>) in
            if let error = NetworkError.init(with: dataResponse) {
                completion(Result.failure(error))
                return
            }
            do {
                let dict = try JSONSerialization.jsonObject(with: dataResponse.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                guard let array = dict as? [JSON] else {
                    completion(Result.failure(.parsingError))
                    return
                }
                completion(Result.success(array))
            }
            catch {
                completion(Result.failure(.parsingError))
            }
        }
    }
}
