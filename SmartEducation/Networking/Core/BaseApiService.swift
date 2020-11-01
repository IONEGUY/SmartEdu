//
//  BaseApiService.swift
//  SmartEducation
//
//  Created by MacBook on 10/31/20.
//

import Foundation
import Alamofire
import RxSwift

class BaseApiService {
    private var errorHandler: ErrorHandler

    init(_ errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
    }

    func request<T: Codable> (_ urlRequestBuilder: URLRequestConvertible) -> Observable<T?> {
        return Observable<T?>.create { [weak self] observer in
            let request = AF.request(urlRequestBuilder)
                .responseDecodable(completionHandler: { [weak self] (response: DataResponse<T?, AFError>) in
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let error):
                        self?.errorHandler.handle(error)
                        observer.onNext(nil)
                        observer.onError(error)
                    }
                })
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
