//
//  LoginViewModel.swift
//  SmartEducation
//
//  Created by MacBook on 1/9/21.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    var loginText = BehaviorRelay<String?>(value: .empty)
    var isLoginButtonEnabled = BehaviorRelay<Bool>(value: false)
   
    private let disposeBag = DisposeBag()
    private let credantialsService: CredantialsServiceProtocol
    private let dialogService: PageDialogServiceProtocol
    
    init(credantialsService: CredantialsServiceProtocol,
         dialogService: PageDialogServiceProtocol) {
        self.credantialsService = credantialsService
        self.dialogService = dialogService
        
        loginText.map { (text: String?) in
            return !(text ?? .empty).isEmptyOrWhitespace() }
        .bind(to: isLoginButtonEnabled)
        .disposed(by: disposeBag)
    }
    
    func performLogin() {
        let text = (loginText.value ?? .empty).trimmingCharacters(in: .whitespaces)
        let success = credantialsService.setCurrentUser(withId: text)
        if success {
            Router.changeRootVC(ChatViewController.self)
        } else {
            dialogService.displayAlert(title: "Error", message: "Login has beed failed")
        }
    }
}
