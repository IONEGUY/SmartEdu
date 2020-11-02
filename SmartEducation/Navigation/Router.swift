//
//  Router.swift
//  SmartEducation
//
//  Created by MacBook on 11/2/20.
//

import Foundation

class Router {
    class func show<VCType: MVVMViewController>(_ vcType: VCType.Type,
                                                params: [String: Any] = [:]) {
        show(vcType, params: params, isModalVC: false)
    }
    
    class func show<VCType: MVVMViewController>(_ vcType: VCType.Type,
                                                params: [String: Any] = [:],
                                                isModalVC: Bool) {
        let currentVC = CurrentViewControllerProvider.getCurrentViewController()
        let navigatingVC = VCType.buildModule(withNavigationParams: params)
        if isModalVC {
            currentVC?.present(navigatingVC, animated: true, completion: nil)
        } else {
            currentVC?.navigationController?.pushViewController(navigatingVC, animated: true)
        }
    }
    
    class func pop() {
        guard let currentVC = CurrentViewControllerProvider.getCurrentViewController() else { return }
        currentVC.dismiss(animated: true, completion: nil)
        currentVC.navigationController?.popViewController(animated: true)
    }
}
