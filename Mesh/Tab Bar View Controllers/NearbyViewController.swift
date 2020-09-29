//
//  NearbyViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/22/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase
import CoreData


class NearbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    

    @IBOutlet weak var nearbyTableView: UITableView!
    
    let database = Firestore.firestore()
    
    var selectedCellIndex: Int?
    
    var lastContentOffset: CGFloat = 0
    
    var testArray: [[String: String]] = []
    
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var localNearbyArray: [NearbyPostsEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        
        UserInfo.refreshTime = Date().timeIntervalSince1970

        nearbyTableView.dataSource = self
        nearbyTableView.delegate = self
        
        nearbyTableView.register(UINib(nibName: "NearbyTableViewCell", bundle: nil), forCellReuseIdentifier: "NearbyTableCellIdentifier")
        
        nearbyTableView.estimatedRowHeight = 150;
        nearbyTableView.rowHeight = UITableView.automaticDimension;
        
        nearbyTableView.layoutMargins = .zero
        nearbyTableView.separatorInset = .zero
        
        loadPostsFromDatabase()
        
        
//        localDataSim()
        
        readLocalData()
        
    }
    
    func localDataSim() {
        
        let arrayCount = NearbyArray.nearbyArray.count
        
        for x in 0...arrayCount {
            print(x)
        }
        
        let coreDataPost = NearbyPostsEntity(context: dataContext)
        coreDataPost.author = "Bobby"
        coreDataPost.comments = [["author": "Harris"]]
        
        do {
            try dataContext.save()
        }
        catch {
        }
    }
    
    
    func readLocalData() {
        
        do {
            self.localNearbyArray = try dataContext.fetch(NearbyPostsEntity.fetchRequest())
        }
        catch {
            
        }
        
        
        let arrayCount: Int = localNearbyArray?.count ?? 0
        
        print("ARRAY COUNT")
        print(arrayCount)
        
        
        if arrayCount > 0 {
            for x in 0...(arrayCount-1) {
                print(x)
                print(localNearbyArray?[x].author ?? nil)
                print(localNearbyArray?[x].message ?? nil)
                print(localNearbyArray?[x].comments ?? nil)

            }
        }
        
        
//        for x in 0...arrayCount {
//            print(x)
//            print(localNearbyArray![x].author)
//            print(localNearbyArray![x].author)
//            print(localNearbyArray![x].author)
//
//
//        }
        
//
//        print("CORE DATA")
//        print(localNearbyArray![3].author)
//        print(localNearbyArray![3].message)
//        print(localNearbyArray![3].comments)

        
    }
    

    
    //Reads posts from database and integrates into local array
    func loadPostsFromDatabase() {
        
        database.collection("posts").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print(err.localizedDescription)
            } else {
                
                for document in querySnapshot!.documents {
                    
                    let postData = document.data()
                    
                    if let postAuthor = postData["author"] as? String,
                        let postMessage = postData["message"] as? String,
                        let postScore = postData["score"] as? Int?,
                        let postTimestamp = postData["timestamp"] as? Double,
                        let postComments = postData["comments"] as? [[String: AnyObject]]?,
                        let postID = document.documentID as String?
                    {
                                                
                        let newPost = NearbyCellData(
                            author: postAuthor,
                            message: postMessage,
                            score: postScore ?? nil,
                            timestamp: postTimestamp,
                            comments: postComments ?? nil,
                            documentID: postID
                        )
                        
                        
                        
//                        print(newPost)
                        
                        NearbyArray.nearbyArray.append(newPost)
                                                
                        DispatchQueue.main.async {
                            self.nearbyTableView.reloadData()
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    //Refreshes tableview after user returns to screen from new post
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.nearbyTableView.reloadData()
        }
    }
    
    
    @IBAction func newPostButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "navTopRightToNewPost", sender: self)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(NearbyArray.nearbyArray.count)
        return NearbyArray.nearbyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nearbyCellData = NearbyArray.nearbyArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyTableCellIdentifier", for: indexPath) as! NearbyTableViewCell
        cell.authorLabel?.text = String(nearbyCellData.author! )
        cell.messageLabel?.text = String(nearbyCellData.message! )
        cell.timestampLabel?.text = formatPostTime(postTimestamp: nearbyCellData.timestamp!)
        
        return cell
        
    }
    
    
    //Converts timestamp from 'seconds since 1970' to readable format
    func formatPostTime(postTimestamp: Double) -> String {
        
        let timeDifference = (UserInfo.refreshTime ?? 0.0) - postTimestamp
        
        var timeInMinutes = Int((timeDifference / 60.0))
        let timeInHours = Int(timeInMinutes / 60)
        let timeInDays = Int(timeInHours / 24)
        
        if timeInMinutes < 60 {
            if timeInMinutes < 1{
                timeInMinutes = 0
            }
            return (String(timeInMinutes) + "m")
        } else if timeInMinutes >= 60 && timeInHours < 23 {
            return (String(timeInHours) + "h")
        } else {
            return (String(timeInDays) + "d")
        }
        
    
    }
    
    //Handles functionality for cell selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellIndex = indexPath.row
//        print(NearbyArray.nearbyArray[indexPath.row])
        performSegue(withIdentifier: "postToComments", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let commentsVC = segue.destination as? CommentsViewController {
            commentsVC.postArrayPosition = selectedCellIndex
        }
        
    }
    
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = nearbyTableView.contentOffset.y
    }
    
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.lastContentOffset < nearbyTableView.contentOffset.y {
            // did move up
        } else if self.lastContentOffset > nearbyTableView.contentOffset.y {
            // did move down
        } else {
            // didn't move
        }
    }


    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        
    }
    
    
    
}


