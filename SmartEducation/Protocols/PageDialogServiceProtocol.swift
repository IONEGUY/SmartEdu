//
//  PageDialogServiceProtocol.swift
//  SmartEducation
//
//  Created by MacBook on 1/10/21.
//

import Foundation

protocol PageDialogServiceProtocol {
    func displayAlert(title: String, message: String)
    
    func displayToast(message: String)
}
