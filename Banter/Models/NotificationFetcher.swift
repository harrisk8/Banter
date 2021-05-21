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
import CoreData
import FirebaseFirestore


protocol updateInboxBadge {
    
    func updateInboxBadge()
    
}


class NotificationFetcher {
    
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let database = Firestore.firestore()
    static var delegate: updateInboxBadge?
    
    var oldNotificationsFromCoreDataRaw: [NotificationEntity] = []

    
    var lastCommentTimestamp = UserDefaults.standard.double(forKey: "lastCommentTimestamp")
    
    //Used for extracting notifications in Step 2 because lastCommentTimestamp is updated after query but before notification processing
    var lastNotificationTimestamp = UserDefaults.standard.double(forKey: "lastCommentTimestamp")


    func getNewNotifications() {

        
        print("Fetching new notifications")
        
        print(UserDefaults.standard.string(forKey: "userCollectionDocID"))
        
        //Query for posts created by user with new comments 
        database.collection("posts")
            .whereField("userDocID", isEqualTo: UserInfo.userCollectionDocID)
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
                        let postUserDocID = postData["userDocID"] as? String,
                        let postLocationCity = postData["locationCity"] as? String,
                        let postLocationState = postData["locationState"] as? String
                        
                    {
                        let newPost = NotificationDataWholePost(
                            author: postAuthor,
                            message: postMessage,
                            score: postScore ?? 0,
                            timestamp: postTimestamp,
                            comments: postComments ?? nil,
                            documentID: postID,
                            lastCommentTimestamp: postLastCommentTimestamp,
                            notifications: postNotifications ?? nil,
                            userDocID: postUserDocID,
                            locationCity: postLocationCity,
                            locationState: postLocationState
                        )
                        
                        print("Adding post to inbox array")
                        NotificationWholePostArray.notificationWholePostArray.append(newPost)
                        
                    }
                }
                
                //Step 1 - Adds posts (whole document) with new comments to intermediate array
                if NotificationWholePostArray.notificationWholePostArray.count != 0 {
                    
                    NotificationWholePostArray.notificationWholePostArray.sort { (lhs: NotificationDataWholePost, rhs: NotificationDataWholePost) -> Bool in
                        return lhs.lastCommentTimestamp ?? 0 > rhs.lastCommentTimestamp ?? 0
                    }
                    
                    //Update lastCommentTimestamp constant
                    UserDefaults.standard.set(NotificationWholePostArray.notificationWholePostArray[0].lastCommentTimestamp, forKey: "lastCommentTimestamp")
                    
                    print(" - - - - - UPDATED TIME STAMP - - - - - ")
                    print((NotificationWholePostArray.notificationWholePostArray[0].lastCommentTimestamp, forKey: "lastCommentTimestamp"))
                    print(UserDefaults.standard.double(forKey: "lastCommentTimestamp"))
                                        
                    //Extracts ALL notifications from intermediate array and passes to second intermediate array
                    for x in 0...(NotificationWholePostArray.notificationWholePostArray.count - 1) {
                        
                        NotificationArrayData.notificationArrayUnsorted.append(contentsOf: NotificationWholePostArray.notificationWholePostArray[x].notifications ?? [])
                        
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
                
                NotificationArrayData.notificationArrayFinal.append(contentsOf: NotificationArrayData.notificationArraySorted)
                
                self.mergeOldNotificationsFromCoreData()
                
                self.addNotifcationsToCoreData()
                
                NotificationArrayData.notificationArrayFinal.sort { (lhs: NotificationDataFormatted, rhs: NotificationDataFormatted) -> Bool in
                    // you can have additional code here
                    return lhs.notificationTimestamp ?? 0 > rhs.notificationTimestamp ?? 0
                }
                
                //Updates badge icon
                NotificationFetcher.self.delegate?.updateInboxBadge()
                
            }
        }
    }
    
    
    
    func addNotifcationsToCoreData() {
        
        if NotificationArrayData.notificationArraySorted.count == 1 {
            
            let notificationForCoreData = NotificationEntity(context: dataContext)
            
            notificationForCoreData.documentID = NotificationArrayData.notificationArraySorted[0].documentID
            notificationForCoreData.message = NotificationArrayData.notificationArraySorted[0].message
            notificationForCoreData.opened = NotificationArrayData.notificationArraySorted[0].opened ?? false
            notificationForCoreData.notificationTimestamp = NotificationArrayData.notificationArraySorted[0].notificationTimestamp ?? 0
            notificationForCoreData.author = NotificationArrayData.notificationArraySorted[0].author
            
            do {
                try dataContext.save()
            }
            catch {
            }
            
            print(" - - - - - Added following Notification to Core Data - - - - - - ")
            print(notificationForCoreData)
        
        } else if NotificationArrayData.notificationArraySorted.count > 1 {
            
            for x in 0...(NotificationArrayData.notificationArraySorted.count - 1) {
                
                let notificationForCoreData = NotificationEntity(context: dataContext)
                
                notificationForCoreData.documentID = NotificationArrayData.notificationArraySorted[x].documentID
                notificationForCoreData.message = NotificationArrayData.notificationArraySorted[x].message
                notificationForCoreData.opened = NotificationArrayData.notificationArraySorted[x].opened ?? false
                notificationForCoreData.notificationTimestamp = NotificationArrayData.notificationArraySorted[x].notificationTimestamp ?? 0
                notificationForCoreData.author = NotificationArrayData.notificationArraySorted[x].author
                
                do {
                    try dataContext.save()
                }
                catch {
                    
                }
                
                print(" - - - - - Added following Notification to Core Data - - - - - - ")
                print(notificationForCoreData)
                
            }
            
        } else {
            print(" - - - - - No new notifications to add to Core Data - - - - - - - ")
        }
        
    }
    
    func mergeOldNotificationsFromCoreData() {
        
        do {
            self.oldNotificationsFromCoreDataRaw = try dataContext.fetch(NotificationEntity.fetchRequest())
        }
        catch {
            
        }
        
        print(" - - - - Notifications in Core Data - - - - - ")
        print(oldNotificationsFromCoreDataRaw.count)
        
        if oldNotificationsFromCoreDataRaw.count == 1 {
            
            let notificationFromCoreData = NotificationDataFormatted(
                author: oldNotificationsFromCoreDataRaw[0].author,
                message: oldNotificationsFromCoreDataRaw[0].message,
                documentID: oldNotificationsFromCoreDataRaw[0].documentID,
                opened: oldNotificationsFromCoreDataRaw[0].opened,
                notificationTimestamp: oldNotificationsFromCoreDataRaw[0].notificationTimestamp
            )
            
            NotificationArrayData.oldNotificationsFromCoreData.append(notificationFromCoreData)
            NotificationArrayData.notificationArrayFinal.append(contentsOf: NotificationArrayData.oldNotificationsFromCoreData)
            
            print(" - - - - One notification pulled FROM Core Data - - - - - ")
            
        } else if oldNotificationsFromCoreDataRaw.count > 1 {
            
            for x in 0...(oldNotificationsFromCoreDataRaw.count - 1) {
                
                let notificationFromCoreData = NotificationDataFormatted(
                    author: oldNotificationsFromCoreDataRaw[x].author,
                    message: oldNotificationsFromCoreDataRaw[x].message,
                    documentID: oldNotificationsFromCoreDataRaw[x].documentID,
                    opened: oldNotificationsFromCoreDataRaw[x].opened,
                    notificationTimestamp: oldNotificationsFromCoreDataRaw[x].notificationTimestamp
                )
                
                NotificationArrayData.oldNotificationsFromCoreData.append(notificationFromCoreData)

                print(" - - - - - Added notification FROM core data - - - - - ")
                print(notificationFromCoreData)
            }
            
            NotificationArrayData.notificationArrayFinal.append(contentsOf: NotificationArrayData.oldNotificationsFromCoreData)

        } else {
            print(" - - - - -  No notifications in core data")
        }
        
    }
    
}
