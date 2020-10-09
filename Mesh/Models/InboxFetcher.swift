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
        
        print("GO")
        
        database.collection("posts")
        .whereField("authorID", isEqualTo: UserInfo.userID ?? "")
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
                        let postLastCommentTimestamp = postData["lastCommentTimestamp"] as? Double
                    {
                        let newPost = InboxCellData(
                            author: postAuthor,
                            message: postMessage,
                            score: postScore ?? 0,
                            timestamp: postTimestamp,
                            comments: postComments ?? nil,
                            documentID: postID,
                            lastCommentTimestamp: postLastCommentTimestamp
                        )
                        
                        print("NEWPOSTSFORNOTIF")
//                        print(newPost)
                        InboxArray.inboxArrayNew.append(newPost)
                        
               
                    }
                    
                    
                    
                }
                
                
                InboxArray.inboxArrayNew.sort { (lhs: InboxCellData, rhs: InboxCellData) -> Bool in
                    // you can have additional code here
                    return lhs.lastCommentTimestamp ?? 0 > rhs.lastCommentTimestamp ?? 0
                }
                
                InboxFetcher.self.delegate?.updateInboxBadge()
            }
        }
    }
    
    
    
    
    
    
}
