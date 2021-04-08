//
//  SceneDelegate.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/7/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

protocol userAuthenticated {
    
    func successfulAuth()
    
}

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var authNotificationDelegate: userAuthenticated?
    
    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == true && UserDefaults.standard.bool(forKey: "userAccountCreated") == true {
            
            if let windowScene = scene as? UIWindowScene {
                self.window = UIWindow(windowScene: windowScene)
                let initialViewController = mainStoryBoard.instantiateViewController(withIdentifier: "tabBarIdentifier")
                self.window!.rootViewController = initialViewController
                self.window!.makeKeyAndVisible()
            }
            
        } else {
            // New User
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let incomingURL = userActivity.webpageURL {
            
            print("Incoming URL is \(incomingURL)")
            
            _ = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                
                guard error == nil else{
                    
                    print("Found an error! \(error!.localizedDescription)")
                    
                    return
                    
                }
                
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
                
            }
        }
    }


    // Handles the link and saves it to userDefaults to assist with login.
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        
        guard let url = dynamicLink.url else {
            print("My dynamic link object has no url")
            return
        }
        
        print("Incoming link parameter is \(url.absoluteString)")

        let link = url.absoluteString
        
        if Auth.auth().isSignIn(withEmailLink: link) {

            print("LINK IS FKIN GOOD")

            // Save link to userDefaults to help finalize login.
            UserDefaults.standard.set(link, forKey: "Link")

            Auth.auth().signIn(withEmail: "harriskapoor98@ufl.edu", link: link) { (user, error) in

                print("The user signed in")
                
                self.authNotificationDelegate?.successfulAuth()

            }
        }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

