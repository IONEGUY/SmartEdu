//
//  Router.swift
//  SmartEducation
//
//  Created by MacBook on 11/2/20.
//

import Foundation
import UIKit

class Router {
    class func show<VCType: MVVMViewController>(_ vcType: VCType.Type,
                                                params: [String: Any] = [:]) {
        show(vcType, params: params, isModalVC: false)
    }

    class private func navigateTo(_ vc: UIViewController?, isModalVC: Bool) {
        guard let vc = vc else { return }
        DispatchQueue.main.async {
            let currentVC = UIApplication.getTopViewController()
            if isModalVC {
                currentVC?.present(vc, animated: false, completion: nil)
            } else {
                currentVC?.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }

    class func show<VCType: MVVMViewController>(_ vcType: VCType.Type,
                                                params: [String: Any] = [:],
                                                isModalVC: Bool) {
        DispatchQueue.main.async {
            let navigatingVC: UIViewController? = VCType.buildModule(withNavigationParams: params)
            navigateTo(navigatingVC, isModalVC: isModalVC)
        }
    }

    class func resolveVC<VCType: MVVMViewController>(_ vcType: VCType.Type,
                                                     params: [String: Any] = [:]) -> UIViewController? {
        return VCType.buildModule(withNavigationParams: params)
    }

    class func pop() {
        DispatchQueue.main.async {
            guard let currentVC =
                    UIApplication.getTopViewController() else { return }
            currentVC.dismiss(animated: true, completion: nil)
            currentVC.navigationController?.popViewController(animated: false)
        }
    }

    class func popTo<VCType: MVVMViewController>(_ vcType: VCType.Type) {
        guard let currentVC =
                UIApplication.getTopViewController() else { return }
        currentVC.navigationController?.viewControllers.forEach { vc in
            if vcType == type(of: vc) {
                currentVC.navigationController?.popToViewController(vc, animated: false)
            }
        }
    }
}
