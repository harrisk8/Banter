//
//  TabBarViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/24/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth


class TabBarViewController: UITabBarController, UITabBarControllerDelegate, updateInboxBadge {
    
    
    //Updates inbox badge count after delegate is called following Firebase query
    func updateInboxBadge() {
        self.tabBar.items![3].badgeValue = String(NotificationArrayData.notificationArraySorted.count)
//        self.tabBar.items![3].badgeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    
    var userClickedNewPost = false
    
    let storyboardInstance = UIStoryboard(name: "Main", bundle: nil)
    
    let database = Firestore.firestore()
    
    let fetcher = NotificationFetcher()
    let startup = StartupSequence()
    
    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientBackground(colorOne: UIColor.blue, colorTwo: UIColor.red)
        
        NotificationFetcher.delegate = self
        
        self.delegate = self

        
        
        //Adds shadow appearing from top of tab bar
        self.tabBar.layer.shadowOpacity = 0.4
        self.tabBar.layer.shadowRadius = 3.5
        self.tabBar.layer.shadowColor = UIColor.black.cgColor
        self.tabBar.layer.masksToBounds = false
        self.tabBar.layer.shadowOffset = (CGSize(width: 0.0, height: 1.0))
        


        
        let userID = Auth.auth().currentUser!.uid
        UserInfo.userID = userID
        print("The userID pulled fresh from tab bar controller is: " + UserInfo.userID!)
        
        UserInfo.userCollectionDocID = UserDefaults.standard.string(forKey: "userCollectionDocID")

                
        fetcher.getNewNotifications()
        startup.pullVotesFromCoreData()
        

    }
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//
//        if userClickedNewPost == true {
//            performSegue(withIdentifier: "tabBarToNewPostEditor", sender: self)
//            userClickedNewPost = false
//            guard let navigationController = storyboard?.instantiateViewController(withIdentifier: "NewPostDummyViewController") as? UINavigationController else { return false }
//
//            present(navigationController, animated: true)
//
//            // Returning false will not open the connected tab bar item view controller you attached to it
//            return true
//        }
//
//        return true
//
//
//    }
    

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == (self.tabBar.items!)[0]{
           print("Nearby")
        }
        else if item == (self.tabBar.items!)[1]{
           print("Trending")
        }
        else if item == (self.tabBar.items!)[2]{
           print("NewPost")
            userClickedNewPost = true
        }
        else if item == (self.tabBar.items!)[3]{
           print("Inbox/Notifications")
        }
        else if item == (self.tabBar.items!)[4]{
           print("Profile")
        }
    }
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        gradientLayer.colors = [colorOne, colorTwo]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        self.tabBar.layer.insertSublayer(gradientLayer, at: 0)

    }
    
    

}
