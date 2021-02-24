//
//  InboxFetcher.swift
//  Mesh
//
//  Created by Harris Kapoor on 10/6/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol updateInboxBadge {
    
    func updateInboxBadge()
    
}


class NotificationFetcher {
    
    let database = Firestore.firestore()
    static var delegate: updateInboxBadge?

    
    var lastCommentTimestamp = UserDefaults.standard.double(forKey: "lastCommentTimestamp")
    
    //Used for extracting notifications in Step 2 because lastCommentTimestamp is updated after query but before notification processing
    var lastNotificationTimestamp = UserDefaults.standard.double(forKey: "lastCommentTimestamp")


    func getNewNotifications() {

        
        print("Fetching new notifications")
        
        //Query for posts created by user with new comments 
        database.collection("posts")
        .whereField("userDocID", isEqualTo: "DzlKdTwTGSM5WdMQikmF")
        .whereField("lastCommentTimestamp", isGreaterThan: lastCommentTimestamp)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
                print("Error fetching documents")
            } else {
                
                for document in querySnapshot!.documents {
                    
                    let postData = document.data()
                    
                    if let postAuthor = postData["author"] as? String,
                        let postMessage = postData["message"] as? String,
                        let postScore = postData["score"] as? Int32?,
                        let postTimestamp = postData["timestamp"] as? Double,
                        let postComments = postData["comments"] as? [[String: AnyObject]]?,
                        let postID = document.documentID as String?,
                        let postLastCommentTimestamp = postData["lastCommentTimestamp"] as? Double,
                        let postNotifications = postData["notifications"] as? [[String: AnyObject]]?,
                        let postUserDocID = postData["userDocID"] as? String
                    {
                        let newPost = NotificationDataRaw(
                            author: postAuthor,
                            message: postMessage,
                            score: postScore ?? 0,
                            timestamp: postTimestamp,
                            comments: postComments ?? nil,
                            documentID: postID,
                            lastCommentTimestamp: postLastCommentTimestamp,
                            notifications: postNotifications ?? nil,
                            userDocID: postUserDocID
                        )
                        
                        print("Adding post to inbox array")
                        NotificationArrayRaw.notificationArrayRaw.append(newPost)
                        
                    }
                }
                
                //Step 1 - Adds posts (whole document) with new comments to intermediate array
                if NotificationArrayRaw.notificationArrayRaw.count != 0 {
                    
                    NotificationArrayRaw.notificationArrayRaw.sort { (lhs: NotificationDataRaw, rhs: NotificationDataRaw) -> Bool in
                        return lhs.lastCommentTimestamp ?? 0 > rhs.lastCommentTimestamp ?? 0
                    }
                    
                    //Update lastCommentTimestamp constant
                    UserDefaults.standard.set(NotificationArrayRaw.notificationArrayRaw[0].lastCommentTimestamp, forKey: "lastCommentTimestamp")
                    
                    print(" - - - - - UPDATED TIME STAMP - - - - - ")
                    print((NotificationArrayRaw.notificationArrayRaw[0].lastCommentTimestamp, forKey: "lastCommentTimestamp"))
                    print(UserDefaults.standard.double(forKey: "lastCommentTimestamp"))
                                        
                    //Extracts ALL notifications from intermediate array and passes to second intermediate array
                    for x in 0...(NotificationArrayRaw.notificationArrayRaw.count - 1) {
                        
                        NotificationArrayData.notificationArrayUnsorted.append(contentsOf: NotificationArrayRaw.notificationArrayRaw[x].notifications ?? [])
                        
                    }
                    
                } else {
                    
                    print("There are no notifications")
                }
                
                
                //Step 2 - Passes notification data from array into notifcation object, populates array with objects
                if NotificationArrayData.notificationArrayUnsorted.count != 0 {
                    
                    for x in 0...(NotificationArrayData.notificationArrayUnsorted.count - 1) {
                        
                        //Extracts notifications that are only new
                        if NotificationArrayData.notificationArrayUnsorted[x]["notificationTimestamp"] as! Double > self.lastNotificationTimestamp {
                            
                            let newNotification = NotificationDataFormatted(author: NotificationArrayData.notificationArrayUnsorted[x]["author"] as? String,
                                                                   message: NotificationArrayData.notificationArrayUnsorted[x]["message"] as? String,
                                                                   documentID: NotificationArrayData.notificationArrayUnsorted[x]["documentID"] as? String,
                                                                   opened: false,
                                                                   notificationTimestamp: NotificationArrayData.notificationArrayUnsorted[x]["notificationTimestamp"] as? Double
                            )
                            
                            
                            NotificationArrayData.notificationArraySorted.append(newNotification)
                            
                        }
                        
                    }
                                        
                    NotificationArrayData.notificationArraySorted.sort { (lhs: NotificationDataFormatted, rhs: NotificationDataFormatted) -> Bool in
                        // you can have additional code here
                        return lhs.notificationTimestamp ?? 0 > rhs.notificationTimestamp ?? 0
                    }
                    
                    
                }
                
                print("New Notifications:")
                print(NotificationArrayData.notificationArraySorted.count)
                print(NotificationArrayData.notificationArraySorted)
                
                //Updates badge icon
                NotificationFetcher.self.delegate?.updateInboxBadge()
                
            }
        }
    }
}
