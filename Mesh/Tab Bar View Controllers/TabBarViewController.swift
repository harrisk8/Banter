//
//  TabBarViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/24/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase


class TabBarViewController: UITabBarController, UITabBarControllerDelegate, updateInboxBadge {
    
    
    //Updates inbox badge count after delegate is called following Firebase query
    func updateInboxBadge() {
        self.tabBar.items![3].badgeValue = String(NotificationArrayData.testInboxArray.count ?? 0)
    }
    
    
    var userClickedNewPost = false
    
    let storyboardInstance = UIStoryboard(name: "Main", bundle: nil)
    
    let database = Firestore.firestore()
    
    let fetcher = InboxFetcher()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        InboxFetcher.delegate = self
        
        let userID = Auth.auth().currentUser!.uid
        UserInfo.userID = userID
                
        fetcher.getNewNotifications()
        
        self.delegate = self

    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if userClickedNewPost == true {
            performSegue(withIdentifier: "tabBarToNewPostEditor", sender: self)
            userClickedNewPost = false
            guard let navigationController = storyboard?.instantiateViewController(withIdentifier: "NewPostDummyViewController") as? UINavigationController else { return false }

            present(navigationController, animated: true)

            // Returning false will not open the connected tab bar item view controller you attached to it
            return true
        }
        
        return true
        
        
    }
    

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
    
    

}
