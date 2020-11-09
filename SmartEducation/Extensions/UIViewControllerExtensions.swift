//
//  UIViewControllerExtensions.swift
//  SmartEducation
//
//  Created by MacBook on 11/8/20.
//

import Foundation
import UIKit

extension UIViewController {
    func setupBaseNavBarStyle() {
        setupNavigationBar()
        setupBackBarButtonItem()
    }

    func setupBackBarButtonItem() {
        let backButton = UIBarButtonItem()
        backButton.title = String.empty
        backButton.tintColor = .black
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }

    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.layoutIfNeeded()
    }
}
