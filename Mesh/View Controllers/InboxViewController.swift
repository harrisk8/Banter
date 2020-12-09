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
        
    var lastCommentTimestampFinal: Double?
    
    var lastCommentTimestamp: Double?
    
    var newNotificationsArray: [NearbyCellData] = []
    
    var selectedCellIndex: Int?
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light


        lastCommentTimestamp = UserDefaults.standard.double(forKey: "lastCommentTimestamp")
        
        print(lastCommentTimestamp ?? 0)
        
        
        inboxTableView.dataSource = self
        inboxTableView.delegate = self
        
        inboxTableView.register(UINib(nibName: "InboxTableCell", bundle: nil), forCellReuseIdentifier: "InboxTableCell")
        
        inboxTableView.estimatedRowHeight = 150;
        inboxTableView.rowHeight = UITableView.automaticDimension;
        
        inboxTableView.layoutMargins = .zero
        inboxTableView.separatorInset = .zero
        
        fetchNewNotifications()
        
        print(UserInfo.userID ?? "")

    }
    
    func getPostData() {
        let thedocid = InboxArray.inboxArrayFetchedPosts[selectedCellIndex ?? 0].documentID
        print(thedocid ?? "")
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellIndex = indexPath.row
        print(indexPath.row)
//        getPostData()
        performSegue(withIdentifier: "inboxToComments", sender: self)
        NotificationArrayData.notificationArray[selectedCellIndex ?? 0].opened = true
        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let commentsVCForInbox = segue.destination as? CommentsViewController {
            commentsVCForInbox.inboxPostArrayPosition = selectedCellIndex
            commentsVCForInbox.modalPresentationCapturesStatusBarAppearance = true
            commentsVCForInbox.segueFromInbox = true
        }
    }
    
    
    func fetchNewNotifications() {
    
        database.collection("posts")
            .whereField("authorID", isEqualTo: UserInfo.userID ?? "")
            .whereField("lastCommentTimestamp", isGreaterThan: 0)
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
                            
//                            print(newPost)
                            self.newNotificationsArray.append(newPost)
                                                                                                                
                            DispatchQueue.main.async {
                                self.inboxTableView.reloadData()
                            }
                            
                                    
                        }
                        
                        self.newNotificationsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
                            // you can have additional code here
                            return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
                        }
                        
                        
                        print(self.newNotificationsArray)
                        
                        
                    }
                    
                                    
                }
            }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationArrayData.notificationArray.count
        return InboxArray.inboxArrayFetchedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
//        let lastCommentDictionary: [[String: AnyObject]] = (InboxArray.inboxArrayFetchedPosts[indexPath.row].comments)!
//
//        let lastComment: [String: AnyObject] = lastCommentDictionary.last!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxTableCell", for: indexPath) as! InboxTableCell
        
//        cell.headerLabel.text = (lastComment["author"] as? String ?? "") + " commented on your post"
//        cell.messageLabel.text = lastComment["message"] as? String
//        cell.timestampLabel.text = "12m"

        cell.headerLabel.text = (NotificationArrayData.notificationArray[indexPath.row].author ?? "") + " commented on your post"
        cell.messageLabel.text = NotificationArrayData.notificationArray[indexPath.row].message
        cell.timestampLabel.text = "12m"

        
        return cell
    }

 
    
}
