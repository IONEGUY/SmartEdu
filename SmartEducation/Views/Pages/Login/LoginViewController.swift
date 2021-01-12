//
//  LoginPage.swift
//  SmartEducation
//
//  Created by MacBook on 1/9/21.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, MVVMViewController {
    typealias ViewModelType = LoginViewModel
    
    private let loginTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.font = UIFont.boldSystemFont(ofSize: 25)
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        return button
    }()
    
    private let container: UIView = {
        let view = UIView()
        return view
    }()
    
    var viewModel: LoginViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = viewModel else { return }
        loginTextField.rx.text.bind(to: viewModel.loginText).disposed(by: disposeBag)
        //loginButton.rx.tap.bind(onNext: viewModel.performLogin).disposed(by: disposeBag)
        viewModel.isLoginButtonEnabled.bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        loginButton.onTap { viewModel.performLogin() }
        setupConstraints()
        
        view.setNeedsUpdateConstraints()
    }
    
    private func setupConstraints() {
        view.addSubview(container)
        container.addSubview(loginTextField)
        container.addSubview(loginButton)
        
        container.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(100)
        }
        loginTextField.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(50)
        }
        loginButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(loginTextField.snp.bottom).offset(10)
        }
    }
}
