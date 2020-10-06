//
//  InboxViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 10/5/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    @IBOutlet weak var inboxTableView: UITableView!
    
    
    let database = Firestore.firestore()
    
    let lastTimestampContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var lastCommentTimestampArray: [LastCommentTimestampEntity]?
    
    var lastCommentTimestampFinal: Double?
    
    var lastCommentTimestamp: Double?
    
    var newNotificationsArray: [NearbyCellData]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        lastCommentTimestamp = UserDefaults.standard.double(forKey: "lastCommentTimestamp")
        
        print(lastCommentTimestamp)
        

    }
    
    
    
    
    func fetchNewNotifications() {
    
        database.collection("posts")
            .whereField("authorID", isEqualTo: UserInfo.userID ?? "")
            .whereField("lastCommentTimestamp", isGreaterThan: lastCommentTimestamp ?? 0.0)
            .getDocuments() { (querySnapshot, err) in
                
                if let err = err {
                    print(err.localizedDescription)
                } else {
                    
                    for document in querySnapshot!.documents {
                        
                        let postData = document.data()
                        
                        if let postAuthor = postData["author"] as? String,
                            let postMessage = postData["message"] as? String,
                            let postScore = postData["score"] as? Int32?,
                            let postTimestamp = postData["timestamp"] as? Double,
                            let postComments = postData["comments"] as? [[String: AnyObject]]?,
                            let postID = document.documentID as String?
                        {
                            let newPost = NearbyCellData(
                                author: postAuthor,
                                message: postMessage,
                                score: postScore ?? 0,
                                timestamp: postTimestamp,
                                comments: postComments ?? nil,
                                documentID: postID
                            )
                                                        
                            self.newNotificationsArray?.append(newPost)
                                    
                        }
                    }
                }
            }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newNotificationsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let lastCommentDictionary: [[String: AnyObject]] = (newNotificationsArray?[indexPath.row].comments)!
        
        let lastComment: [String: AnyObject] = lastCommentDictionary.last!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxableCell", for: indexPath) as! InboxTableCell
        
        cell.headerLabel.text = lastComment["author"] as? String
        cell.messageLabel.text = lastComment["message"] as? String
        cell.timestampLabel.text = lastComment["timestamp"] as? String


        
        return cell
    }

    func testFunc() {
        
        
        for post in newNotificationsArray! {
            
            
            
        }
    }
    
    
    
    
    func addTestData() {
        
        let coreDataLastCommentTimestamp = LastCommentTimestampEntity(context: lastTimestampContext)
                    
        coreDataLastCommentTimestamp.lastCommentTimestamp = 100.0
        
        do {
            try lastTimestampContext.save()
        }
        catch {
        }
        
    }
    
    
    func fetchLastCommentTimestamp() {
        
        do {
            self.lastCommentTimestampArray = try lastTimestampContext.fetch(LastCommentTimestampEntity.fetchRequest())
        }
        catch {
            
        }
        
        let arrayCount: Int = lastCommentTimestampArray?.count ?? 0
        
        print("ARRAY COUNT")
        print(arrayCount)
        
        if arrayCount > 0 {
            for x in 0...(arrayCount-1) {
        
                print(x)
                
        
            }
            

        }
    
    }
    
    
    
}
