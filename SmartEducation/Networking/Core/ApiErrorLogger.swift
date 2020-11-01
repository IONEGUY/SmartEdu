//
//  Logger.swift
//  SmartEducation
//
//  Created by MacBook on 10/31/20.
//

import Foundation
import Alamofire

class ApiErrorLogger: ErrorHandler {
    func handle(_ error: Error) {
        print(error)
    }
}
