//
//  AppDelegate.swift
//  SmartEducation
//
//  Created by MacBook on 10/20/20.
//

import UIKit
import JitsiMeet

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initJitSiApp(launchOptions, application)
        DIContainerConfigurator.initiate()
        initializeWindow()
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

    private func initializeWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController =
            UINavigationController(rootViewController: FieldsOfScienceViewController.buildModule())
        window?.makeKeyAndVisible()
    }

    private func initJitSiApp(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?, _ application: UIApplication) {
        if launchOptions != nil {
            JitsiMeet.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions!)
        }
    }
}
