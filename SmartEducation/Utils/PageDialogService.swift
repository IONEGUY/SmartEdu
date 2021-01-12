//
//  PageDialogService.swift
//  SmartEducation
//
//  Created by MacBook on 1/10/21.
//

import Foundation
import UIKit

class PageDialogService: PageDialogServiceProtocol {
    func displayAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }))

            var rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            }

            rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func displayToast(message: String) {
        DispatchQueue.main.async {
            let verticalOffset: CGFloat = 100
            let horizontalOffset: CGFloat = 75
            let screenBounds = UIScreen.main.bounds;
            let toastLabel = UILabel(frame: CGRect(x: screenBounds.width / 2 - horizontalOffset,
                                                   y: screenBounds.height - verticalOffset,
                                                   width: 150, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds = true
            UIApplication.shared.windows.first?.rootViewController?.view.addSubview(toastLabel)
            UIView.animate(withDuration: 2.0, delay: 4, options: .curveEaseOut, animations: {
                 toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    }
}
