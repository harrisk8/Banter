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

class InboxFetcher {
    
    let database = Firestore.firestore()
    
    var lastCommentTimestamp = UserDefaults.standard.double(forKey: "lastCommentTimestamp")
    
    static var delegate: updateInboxBadge?

    func getNewNotifications() {
        
        print("Fetching new notifications")
        
        database.collection("posts")
        .whereField("userDocID", isEqualTo: "DzlKdTwTGSM5WdMQikmF")
        .whereField("lastCommentTimestamp", isGreaterThan: 0)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
                print("nodocs")
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
                        let newPost = InboxCellData(
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
                        InboxArray.inboxArrayNew.append(newPost)
                        print(newPost)
                        
                    }
    
                }
                
                
                                

                if InboxArray.inboxArrayNew.count != 0 {
                    
                    InboxArray.inboxArrayNew.sort { (lhs: InboxCellData, rhs: InboxCellData) -> Bool in
                        // you can have additional code here
                        return lhs.lastCommentTimestamp ?? 0 > rhs.lastCommentTimestamp ?? 0
                    }
                    
//                    UserDefaults.standard.set(InboxArray.inboxArrayNew[0].timestamp, forKey: "lastCommentTimestamp")
                    
                    for x in 0...(InboxArray.inboxArrayNew.count - 1) {
                        
//                        if InboxArray.inboxArrayNew[x].notifications?.count != 0 {
//
//                            NotificationArrayData.testInboxArray?.append(contentsOf: InboxArray.inboxArrayNew[x].notifications ?? [])
//
//                        }
                        
                        print("INBOX ARRAY POST")
                        print(InboxArray.inboxArrayNew[x])
                        
                        print("INBOX ARRAY NOTIFS")
                        print(InboxArray.inboxArrayNew[x].notifications as Any)
                        print(InboxArray.inboxArrayNew[x].notifications?.count)
                        
                        
                        NotificationArrayData.testInboxArray.append(contentsOf: InboxArray.inboxArrayNew[x].notifications ?? [])
                        
//                        for y in 0...((InboxArray.inboxArrayNew[x].notifications?.count ?? 1)){
//
//                            NotificationArrayData.testInboxArray?.append(InboxArray.inboxArrayNew[x].notifications?[y] ?? [:])
//
//                        }
                        

                    
                    }
                } else {
                    print("There are no notifications")
                }
                
                print("NOTIFICATIONS ARE:")
                print(NotificationArrayData.testInboxArray as Any)
                
                
                InboxArray.inboxArrayNew.sort { (lhs: InboxCellData, rhs: InboxCellData) -> Bool in
                    // you can have additional code here
                    return lhs.lastCommentTimestamp ?? 0 > rhs.lastCommentTimestamp ?? 0
                }
                
                InboxFetcher.self.delegate?.updateInboxBadge()
            }
        }
    }
    
    
    
    
    
    
}
