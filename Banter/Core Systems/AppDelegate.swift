//
//  AppDelegate.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/7/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
import FirebaseMessaging

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    fileprivate var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications() // here your alert with Permission will appear
        
        isAppAlreadyLaunchedOnce()

        FirebaseApp.configure()
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func handlePasswordlessSignIn(withURL url: URL) -> Bool {
        let link = url.absoluteString
        // [START is_signin_link]
        if Auth.auth().isSignIn(withEmailLink: link) {
          // [END is_signin_link]
          UserDefaults.standard.set(link, forKey: "Link")
            print("USER SIGNED IN!")
          return true
        }
        return false
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

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "localDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    func isAppAlreadyLaunchedOnce()->Bool{
        
        let defaults = UserDefaults.standard

        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
            UserDefaults.standard.set(true, forKey: "userLaunchedBefore")
            return true
        }else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            UserDefaults.standard.set(false, forKey: "userLaunchedBefore")
            print("App launched first time")
            return false
        }
    }
    

}


