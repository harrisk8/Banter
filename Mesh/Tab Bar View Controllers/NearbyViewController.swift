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
        
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var previousTimestamp: Double?
    var timestampRefreshed: Double?

    
    var testArray: [NearbyCellData]?
    
    
    var localNearbyArray: [NearbyPostsEntity]?
    
    var localDataScanned = false
    var newDataScanned = false
    
    var lastPostTimestamp: Double?
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        
        UserInfo.refreshTime = Date().timeIntervalSince1970

        nearbyTableView.dataSource = self
        nearbyTableView.delegate = self
        
        nearbyTableView.register(UINib(nibName: "NearbyTableCell", bundle: nil), forCellReuseIdentifier: "NearbyTableCell")
        
        nearbyTableView.estimatedRowHeight = 150;
        nearbyTableView.rowHeight = UITableView.automaticDimension;
        
        nearbyTableView.layoutMargins = .zero
        nearbyTableView.separatorInset = .zero
        
        loadPostsFromDatabase()

    }

    
    
    

    
    //Reads posts from database and integrates into local array
    func loadPostsFromDatabase() {
        
        //Updates local timestamp of moment refreshed
        timestampRefreshed = Date().timeIntervalSince1970
        print(timestampRefreshed ?? 0)

        
        //Existing Post Load
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == true {
            
            print("EXISTING USER")
            
            readLocalData()
            retrieveLastPostTimestamp()
            
            //Fetch last timestamp refreshed and update new refresh timestamp
            previousTimestamp = UserDefaults.standard.double(forKey: "lastRefreshTimestamp")
            UserDefaults.standard.set(timestampRefreshed, forKey: "lastRefreshTimestamp")
            
            print("Timestamp Refreshed")
            print(timestampRefreshed ?? 0)
            print("Previous refresh")
            print(previousTimestamp ?? 0)
            print("New refresh timestamp stored")
            print(UserDefaults.standard.double(forKey: "lastRefreshTimestamp"))

            
            if timestampRefreshed ?? 0 > lastPostTimestamp ?? 0 {
                print("Check database")
                fetchNewPosts()
            }
            
    
            
            
            
            self.testArray?.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
                return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
            }
            
        }
        
        
        //New User Post Load, assumes locality has content
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == false {
            print("NEWBIE")
            
            UserDefaults.standard.set(timestampRefreshed, forKey: "lastRefreshTimestamp")
            print(UserDefaults.standard.double(forKey: "lastRefreshTimestamp"))
            
            fetchAllPostsForLocality()

        }
        
//        database.collection("posts").getDocuments() { (querySnapshot, err) in
//
//            if let err = err {
//                print(err.localizedDescription)
//            } else {
//
//                for document in querySnapshot!.documents {
//
//                    let postData = document.data()
//
//                    if let postAuthor = postData["author"] as? String,
//                        let postMessage = postData["message"] as? String,
//                        let postScore = postData["score"] as? Int32?,
//                        let postTimestamp = postData["timestamp"] as? Double,
//                        let postComments = postData["comments"] as? [[String: AnyObject]]?,
//                        let postID = document.documentID as String?
//                    {
//
//                        let newPost = NearbyCellData(
//                            author: postAuthor,
//                            message: postMessage,
//                            score: postScore ?? nil,
//                            timestamp: postTimestamp,
//                            comments: postComments ?? nil,
//                            documentID: postID
//                        )
//
//
//
//
////                        print(newPost)
//
//                        NearbyArray.nearbyArray.append(newPost)
//
//                        DispatchQueue.main.async {
//                            self.nearbyTableView.reloadData()
//                        }
//
//
//                    }
//                }
//
//                self.testArray = NearbyArray.nearbyArray
//
//                self.testArray?.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
//                    // you can have additional code here
//                    return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
//                }
//
//                for x in 0...(self.testArray!.count - 1) {
//
//
//
//                    let ts = self.testArray?[x].timestamp ?? 0.0
//
//
////                    print(self.formatPostTime(postTimestamp: ts))
//                }
//
//
//            }
//        }
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
        
        if arrayCount > 0 && localDataScanned == false {
            for x in 0...(arrayCount-1) {
        
                print(x)
                
                let transferCellData = NearbyCellData(
                    author: localNearbyArray?[x].author as String?,
                    message: localNearbyArray?[x].message as String?,
                    score: localNearbyArray?[x].score as Int32?,
                    timestamp: localNearbyArray?[x].timestamp as Double?,
                    comments: localNearbyArray?[x].comments as? [[String: AnyObject]],
                    documentID: localNearbyArray?[x].documentID as String?
                )
                
                formattedPosts.formattedPostsArray.append(transferCellData)
                print(transferCellData)

            }
            

        }
        print(formattedPosts.formattedPostsArray.count)
        print(formattedPosts.formattedPostsArray)
        
    }
    
    func addPostsToCoreData() {
        
        
        if NearbyArray.nearbyArray.count == 1 {
            
            let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                        
            coreDataPostCell.author = NearbyArray.nearbyArray[0].author
            coreDataPostCell.comments = NearbyArray.nearbyArray[0].comments as NSArray?
            coreDataPostCell.documentID = NearbyArray.nearbyArray[0].documentID
            coreDataPostCell.message = NearbyArray.nearbyArray[0].message
            coreDataPostCell.score = (NearbyArray.nearbyArray[0].score as Int32?) ?? 0
            coreDataPostCell.timestamp = NearbyArray.nearbyArray[0].timestamp ?? 0.0
            
            print("adding one new post")
            
            do {
                try dataContext.save()
            }
            catch {
            }
            
        } else if NearbyArray.nearbyArray.count > 1 {
            
            for x in 0...((NearbyArray.nearbyArray.count) - 1) {
                
                let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                            
                coreDataPostCell.author = NearbyArray.nearbyArray[x].author
                coreDataPostCell.comments = NearbyArray.nearbyArray[x].comments as NSArray?
                coreDataPostCell.documentID = NearbyArray.nearbyArray[x].documentID
                coreDataPostCell.message = NearbyArray.nearbyArray[x].message
                coreDataPostCell.score = (NearbyArray.nearbyArray[x].score as Int32?) ?? 0
                coreDataPostCell.timestamp = NearbyArray.nearbyArray[x].timestamp ?? 0.0
                
                print("adding mulitple")
                print(x)
                
                do {
                    try dataContext.save()
                }
                catch {
                }
                
            }
        } else {
            print("no new posts to add")
        }
        
        organizeArrayForTableView()
                
    }
    
    
    
    
    //Fetches new posts after comparing previous timestamp to new timestamp (Existing users)
    func fetchNewPosts() {
        
        database.collection("posts").whereField("timestamp", isGreaterThan: lastPostTimestamp!).getDocuments() { (querySnapshot, err) in
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
                        
                        NearbyArray.nearbyArray.append(newPost)
                        print(newPost)
                                                
                        DispatchQueue.main.async {
                            self.nearbyTableView.reloadData()
                        }
                        
                    }
                    
                }
                
                
                print("NEWPOSTS")
                print(NearbyArray.nearbyArray.count)
                self.addPostsToCoreData()
                
            }
                                
        }
        
        
        

    }
    
    func fetchAllPostsForLocality() {
        
        database.collection("posts").getDocuments() { (querySnapshot, err) in
                
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
                            
                            NearbyArray.nearbyArray.append(newPost)
                            print(newPost)
                            
                        
                                                    
                            DispatchQueue.main.async {
                                self.nearbyTableView.reloadData()
                            }
                        }
                    }
                    self.addPostsToCoreData()
                    print(NearbyArray.nearbyArray.count)

                }
        

            }
        
        
    }
    
    func organizeArrayForTableView() {
        
        print("ORGANIZING")
        formattedPosts.formattedPostsArray.append(contentsOf: NearbyArray.nearbyArray)
        
        print(NearbyArray.nearbyArray.count)
        
        formattedPosts.formattedPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
            // you can have additional code here
            return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
        }
        
        DispatchQueue.main.async {
            self.nearbyTableView.reloadData()
        }
        
    }
    
    func retrieveLastPostTimestamp() {
        
        formattedPosts.formattedPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
            // you can have additional code here
            return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
        }
        
        lastPostTimestamp = formattedPosts.formattedPostsArray[0].timestamp ?? 0
        print(lastPostTimestamp)
        print(formattedPosts.formattedPostsArray)
        
        
        
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
        return formattedPosts.formattedPostsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nearbyCellData = formattedPosts.formattedPostsArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyTableCell", for: indexPath) as! NearbyTableCell
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


