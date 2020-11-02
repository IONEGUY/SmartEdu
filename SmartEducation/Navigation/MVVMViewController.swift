//
//  MVVMViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/2/20.
//

import Foundation
import UIKit

protocol MVVMViewController where Self: UIViewController {
    associatedtype ViewModelType

    var viewModel: ViewModelType? { get set }
    static func buildModule(withNavigationParams: [String: Any]) -> Self
}

extension MVVMViewController {
    static func buildModule(withNavigationParams: [String: Any] = [:]) -> Self {
        let viewController = Self()
        let viewModel = DIContainerConfigurator.container.resolve(ViewModelType.self)
        viewController.viewModel = viewModel
        (viewModel as? NavigatedToAware)?.navigatedTo(withNavigationParams)
        return viewController
    }
}
