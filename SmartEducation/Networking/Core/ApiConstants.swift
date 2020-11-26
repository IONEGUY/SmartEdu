//
//  APIConstants.swift
//  SmartEducation
//
//  Created by MacBook on 10/30/20.
//

import Foundation
import Alamofire

struct ApiConstants {
    static let baseUrl = "https://jsonplaceholder.typicode.com"

    static let conferenceUrl = "https://smarteducation-zain-test.awtg.co.uk/"
    
    static let streamURl = "http://77.232.100.137:8082/hls/SmartEDU.m3u8"

    struct Parameters {

    }

    enum HttpHeaderField: String {
        case authentication = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
    }

    enum ContentType: String {
        case json = "application/json"
    }
}
