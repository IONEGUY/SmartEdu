//
//  DIContainerConfigurator.swift
//  SmartEducation
//
//  Created by MacBook on 11/2/20.
//

import Foundation
import Swinject
import SwinjectAutoregistration

class DIContainerConfigurator {
    static var container = Container()

    static func initiate() {
        registerViewModels()
        registerServices()
    }

    private static func registerViewModels() {
//        container.autoregister(ViewModel.self, initializer: ViewModel.init)
    }

    private static func registerServices() {
//        container.autoregister(SomeServiceProtocol1.self, initializer: SomeService1.init)
    }
}
