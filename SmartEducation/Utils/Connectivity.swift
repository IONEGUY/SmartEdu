//
//  NetworkConnectivityService.swift
//  SmartEducation
//
//  Created by MacBook on 1/26/21.
//

import Foundation
import Alamofire

class Connectivity {
    class var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
