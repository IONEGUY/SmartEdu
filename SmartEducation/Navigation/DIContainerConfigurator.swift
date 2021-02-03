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
        container.autoregister(FieldsOfScienceViewModel.self, initializer: FieldsOfScienceViewModel.init)
        container.autoregister(SciencesViewModel.self, initializer: SciencesViewModel.init)
        container.autoregister(SpecificScienceViewModel.self, initializer: SpecificScienceViewModel.init)
        container.autoregister(TableViewWithTitleViewModel.self, initializer: TableViewWithTitleViewModel.init)
        container.autoregister(VolumetricModeViewModel.self, initializer: VolumetricModeViewModel.init)
        container.autoregister(ChatViewModel.self, initializer: ChatViewModel.init)
        container.autoregister(ImageRecognitionViewModel.self, initializer:
            ImageRecognitionViewModel.init)
        container.autoregister(LoginViewModel.self, initializer: LoginViewModel.init)
    }
    
    private static func registerServices() {
        container.autoregister(ChatServiceProtocol.self, initializer: FirebaseChatService.init)
        container.autoregister(ChatManagerProtocol.self, initializer: ChatManager.init)
        container.autoregister(RepositoryProtocol.self, initializer: Repository.init)
        container.autoregister(CredantialsServiceProtocol.self, initializer: CredantialsService.init)
        container.autoregister(PageDialogServiceProtocol.self, initializer: PageDialogService.init)
    }
}
