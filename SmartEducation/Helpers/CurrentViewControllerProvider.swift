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
        var viewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        if let navigationController = viewController as? UINavigationController {
            viewController = navigationController.viewControllers.first
        }
        if let tabBarController = viewController as? UITabBarController {
            viewController = tabBarController.selectedViewController
        }

        return viewController
    }
}
