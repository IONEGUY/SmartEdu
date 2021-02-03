//
//  AppDelegate.swift
//  SmartEducation
//
//  Created by MacBook on 10/20/20.
//

import UIKit
import IQKeyboardManagerSwift
import JitsiMeet
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Firebase
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initJitSiApp(launchOptions, application)
        initCrashlytics()
        initDefaultRealmConfiguration()
        FirebaseApp.configure()
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

    private func initCrashlytics() {
        AppCenter.start(withAppSecret: "bb4a8a08-0253-4146-81ae-f0402cff843d", services: [
            Analytics.self,
            Crashes.self
        ])
    }

    private func initJitSiApp(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?, _ application: UIApplication) {
        if launchOptions != nil {
            JitsiMeet.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions!)
        }
    }

    private func initializeWindow() {
        guard let credantialsService =
            DIContainerConfigurator.container.resolve(CredantialsServiceProtocol.self) else { return }
        credantialsService.isUserLoggedIn()
            ? Router.changeRootVC(ChatViewController.self)
            : Router.changeRootVC(LoginViewController.self)
    }

    private func initDefaultRealmConfiguration() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
}
