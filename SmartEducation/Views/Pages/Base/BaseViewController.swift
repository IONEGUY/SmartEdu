//
//  BaseViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/8/20.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLeftBarButtonItem()
    }
    
    private func setupLeftBarButtonItem() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 15, height: 25))
        imageView.image = UIImage(named: "back")
        view.addSubview(imageView)
        let backTap = UITapGestureRecognizer(target: self,
                                             action: #selector(backButtonPressed))
        view.addGestureRecognizer(backTap)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
    }

    @objc func backButtonPressed() {
        Router.pop()
    }
}
