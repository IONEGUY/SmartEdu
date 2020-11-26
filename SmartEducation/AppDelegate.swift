//
//  AppDelegate.swift
//  SmartEducation
//
//  Created by MacBook on 10/20/20.
//

import UIKit
import IQKeyboardManagerSwift
import JitsiMeet

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initJitSiApp(launchOptions, application)
        IQKeyboardManager.shared.enable = true
        DIContainerConfigurator.initiate()
        initializeWindow()
        GlobalStyles.create()
        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return JitsiMeet.sharedInstance().application(application,
                                                      continue: userActivity,
                                                      restorationHandler: restorationHandler)
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return JitsiMeet.sharedInstance().application(app, open: url, options: options)
    }

    private func initJitSiApp(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?, _ application: UIApplication) {
        if launchOptions != nil {
            JitsiMeet.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions!)
        }
    }
    
    private func initializeWindow() {
        guard let rootViewController = Router.resolveVC(FieldsOfScienceViewController.self) else {
            fatalError("cannot resolve root view controller")
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController =
            UINavigationController(rootViewController: rootViewController)
        window?.makeKeyAndVisible()
    }
}
