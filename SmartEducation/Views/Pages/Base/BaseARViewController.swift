//
//  BaseARViewController.swift
//  SmartEducation
//
//  Created by MacBook on 11/9/20.
//

//import UIKit
//
//class BaseARViewController: UIViewController, MVVMViewController {
//    typealias ViewModelType = BaseARViewModel
//
//    var viewModel: BaseARViewModel?
//
//    private var imageRecognitionViewController: UIViewController?
//    private var volumetricModeViewController: UIViewController?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        imageRecognitionViewController = Router.resolveVC(ImageRecognitionViewController.self)
//        volumetricModeViewController = Router.resolveVC(VolumetricModeViewController.self)
//
//        setupBaseNavBarStyle()
//        setupRightBarButtonItem()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        setupChildViewController()
//    }
//
//    private func setupChildViewController() {
//        guard let viewController: UIViewController = viewModel?.planeModeSelected ?? true
//            ? imageRecognitionViewController
//            : volumetricModeViewController
//            else { return }
//
//        view.subviews.forEach { $0.removeFromSuperview() }
//        view.addSubview(viewController.view)
//        view.layoutSubviews()
//    }
//}
