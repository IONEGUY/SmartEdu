//
//  APIConfiguration.swift
//  SmartEducation
//
//  Created by MacBook on 10/30/20.
//

import Foundation
import Alamofire

struct URLRequestBuilder: URLRequestConvertible {
    var method: HTTPMethod
    var path: String
    var parameters: Parameters?

    init(_ method: HTTPMethod, _ path: String, _ parameters: Parameters?) {
        self.method = method
        self.path = path
        self.parameters = parameters
    }

    func asURLRequest() throws -> URLRequest {
        let url = try ApiConstants.baseUrl.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))

        urlRequest.httpMethod = method.rawValue

        urlRequest.setValue(ApiConstants.ContentType.json.rawValue,
                            forHTTPHeaderField: ApiConstants.HttpHeaderField.acceptType.rawValue)
        urlRequest.setValue(ApiConstants.ContentType.json.rawValue,
                            forHTTPHeaderField: ApiConstants.HttpHeaderField.contentType.rawValue)

        let encoding: ParameterEncoding = {
            switch method {
            case .get:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()

        return try encoding.encode(urlRequest, with: parameters)
    }
}
