//
//  APIHandler.swift
//  iROID_Test
//
//  Created by Athira on 18/09/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation
import Alamofire
import MBProgressHUD
class APIHandler{
    static let sharedInstance = APIHandler()
    
    typealias CallbackType = ( _ success: Bool,  _ responseDict: [String: Any], _ error: Error?) -> Void
    typealias CallbackType2 = ( _ success: Bool,  _ responseArray: [Any], _ error: Error?) -> Void
    
    struct Constants {
        #if DEBUG
        
        
            fileprivate static let baseURL            =    "http://iroidtechnologies.in/"
        #else
            fileprivate static let baseURL            =   "http://iroidtechnologies.in/"
        #endif
            static let apiUrl                         =    "friday/index.php?route=api/common"
         
    }
    // MARK:- APi calling using Main base url - GET
    //----------------------------------------------
    
    func doAPIPostCallForMethodGET(_ url: String, view: UIView, authorization:String ,callback: @escaping CallbackType) {
        let url = "\(Constants.baseURL)\(url)"
        MBProgressHUD.showAdded(to: view, animated: true)
        let methodType = Alamofire.HTTPMethod.get
        let encoding = JSONEncoding.prettyPrinted //Alamofire.ParameterEncoding.JSON
        let headers = ["Authorization" : authorization]
        print("URL========>", url)
        Alamofire.request(url, method: methodType, parameters: nil, encoding: encoding, headers: headers).validate().responseJSON { (response) in
        MBProgressHUD.hide(for: view, animated: true)
        switch response.result {
                case .success:
                if let value = response.result.value {
                    let mainDict = value as! [String: Any]
                    print("The response=====>",mainDict)
                    callback(true, mainDict, nil)}
                    case .failure(let error):
                    if (response.result.error as? AFError) != nil
                    {
                        switch response.response?.statusCode  {
                        case 401:
                            let callBackDict = ["status" : "2" , "message" : "Please Logout to continue"] as [String : Any]
                            callback(false, callBackDict, error)
                        break
                        case 500:
                            let callBackDict = ["status" : "2" , "message" : "Internal Server Error"] as [String : Any]
                            callback(false, callBackDict, error)
                        break
                        default:
                        break
                            }
                        }else
                        {
                            switch (response.error!._code)
                            {
                                case NSURLErrorTimedOut:
                                    let callBackDict = ["status" : "2" , "message" : "Time Out"] as [String : Any]
                                    callback(false, callBackDict, error)
                                break
                                case NSURLErrorNotConnectedToInternet:
                                    let callBackDict = ["status" : "2" , "message" : "Please check your internet connection"] as [String : Any]
                                    callback(false, callBackDict, error)
                                break
                                default: break
                            }
                        }
                    }
                }
            }
}
