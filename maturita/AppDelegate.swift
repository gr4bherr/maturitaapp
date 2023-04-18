//
//  AppDelegate.swift
//  maturita
//
//  Created by grabherr on 27.03.2021.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //function compresses database (only for releasing, doesn't run in day to day use)
    func compactRealm() {
        let defaultURL = Realm.Configuration.defaultConfiguration.fileURL!
        let defaultParentURL = defaultURL.deletingLastPathComponent()
        let compactedURL = defaultParentURL.appendingPathComponent("default-compact.realm")

        autoreleasepool {
            let realm = try! Realm()
            try! realm.writeCopy(toFile: compactedURL)
        }
//        try! FileManager.default.removeItem(at: defaultURL)
//        try! FileManager.default.moveItem(at: compactedURL, to: defaultURL)
    }
    //function copies database that comes with app and replaces user database
    func writeFromFile() {
        let defaultURL = Realm.Configuration.defaultConfiguration.fileURL!
        let bundledRealmURL = Bundle.main.url(forResource: "default", withExtension: "realm")!

        try! FileManager.default.removeItem(at: defaultURL)
        try! FileManager.default.copyItem(at: bundledRealmURL, to: defaultURL)
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        compactRealm()
        
        do {
            let realm = try Realm()
            print(Realm.Configuration.defaultConfiguration.fileURL!)
            if realm.isEmpty {
                writeFromFile()
            }
        } catch {
            print("Error initialising new realm, \(error)")
        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

