//
//  BaseARViewModel.swift
//  SmartEducation
//
//  Created by MacBook on 11/9/20.
//

import Foundation

class BaseARViewModel {
    var planeModeSelected = true
    var imageName: String {
        return planeModeSelected ? "cube" : "capture"
    }

    var pageToggledCommand: (() -> Void)?

    init() {
        pageToggledCommand = pageToggled
    }

    private func pageToggled() {
        planeModeSelected.toggle()
    }
}
