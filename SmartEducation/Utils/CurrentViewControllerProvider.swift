//
//  CurrentViewControllerProvider.swift
//  SmartEducation
//
//  Created by MacBook on 11/2/20.
//

import Foundation
import UIKit

class CurrentViewControllerProvider {
    class func getCurrentViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        var topController = keyWindow?.rootViewController
        if let vc = topController {
            while let presentedViewController = vc.presentedViewController {
                topController = presentedViewController
            }
        }
        
        return topController
    }
}
