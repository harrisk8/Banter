//
//  TrendingViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 9/14/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase

class TrendingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var trendingTableView: UITableView!
    
    
    let database = Firestore.firestore()
    private let refreshControl = UIRefreshControl()

    var refreshFetchedPosts: [TrendingCellData] = []

    var lastTrendingFetchTimestamp: Double?

    //Stores the index of cell tapped by the user. Used to pull post info from array with same index on next VC.
    var selectedCellIndex: Int?
    
    var lowestScoreInTable: Int32?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        trendingTableView.dataSource = self
        trendingTableView.delegate = self
        trendingTableView.register(UINib(nibName: "TrendingTableCell", bundle: nil), forCellReuseIdentifier: "TrendingTableCell")
        trendingTableView.estimatedRowHeight = 150;
        trendingTableView.rowHeight = UITableView.automaticDimension;
        trendingTableView.layoutMargins = .zero
        trendingTableView.separatorInset = .zero
        
        trendingTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshedTableView), for: .valueChanged)
        
        fetchNewPosts()
    }
    
    
    @objc func refreshedTableView() {
        refreshFetchedPosts = []
        print("TRENDING: Refreshed received")
        checkNewPostsForRefresh()
        self.refreshControl.endRefreshing()
    }
    
    func checkNewPostsForRefresh() {
        
        print("REFRESH: Checking for new posts")
        
        if formattedTrendingPosts.formattedTrendingPostsArray.count == 0 {
            lastTrendingFetchTimestamp = 0.0
        }
        
        print(lastTrendingFetchTimestamp)

        database.collection("posts").order(by: "score").limit(to: 30) .getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print(err.localizedDescription)
            } else {
                
                self.lastTrendingFetchTimestamp = Date().timeIntervalSince1970
                
                for document in querySnapshot!.documents {
                    let postData = document.data()
                    
                    if let postAuthor = postData["author"] as? String,
                        let postMessage = postData["message"] as? String,
                        let postScore = postData["score"] as? Int32?,
                        let postTimestamp = postData["timestamp"] as? Double,
                        let postComments = postData["comments"] as? [[String: AnyObject]]?,
                        let postID = document.documentID as String?,
                        let postLocationCity = postData["locationCity"] as? String,
                        let postLocationState = postData["locationState"] as? String
                    {

                        let newPost = TrendingCellData(
                            author: postAuthor,
                            message: postMessage,
                            score: postScore,
                            timestamp: postTimestamp,
                            comments: postComments,
                            documentID: postID,
                            postLocationCity: postLocationCity,
                            postLocationState: postLocationState
                        )
                        
                        print(newPost)
                        
                        //Appends new post to intermediate refresh array
                        self.refreshFetchedPosts.append(newPost)
                        
                    }
                }
                
                //Updates lastTimestampPulledFromServer only if new post is fetched
                if self.refreshFetchedPosts.count != 0 {
                    
                    //Empties tending array
                    formattedTrendingPosts.formattedTrendingPostsArray = []

                    //Adds all posts from the intermediate refresh array to final nearby array
                    formattedTrendingPosts.formattedTrendingPostsArray.append(contentsOf: self.refreshFetchedPosts)
                    
                    //Sort by timestamp
                    formattedTrendingPosts.formattedTrendingPostsArray.sort { (lhs: TrendingCellData, rhs: TrendingCellData) -> Bool in
                        return lhs.score ?? 0 > rhs.score ?? 0
                    }
                    
                    
                    
                } else {
                    
                    print(" - - - - - - REFRESH: There are no new posts - - - - - ")
                    
                }
                
                DispatchQueue.main.async {
                    self.trendingTableView.reloadData()
                }
                
            }
        }
    }
    
    
    //Fetches trending posts from server upon opening VC for first time
    func fetchNewPosts() {
        
        database.collection("posts").order(by: "score").limit(to: 30).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
                print("nodocs")
            } else {
                
                self.lastTrendingFetchTimestamp = Date().timeIntervalSince1970
                
                for document in querySnapshot!.documents {
                    let postData = document.data()
                    
                    if let postAuthor = postData["author"] as? String,
                        let postMessage = postData["message"] as? String,
                        let postScore = postData["score"] as? Int32?,
                        let postTimestamp = postData["timestamp"] as? Double,
                        let postComments = postData["comments"] as? [[String: AnyObject]]?,
                        let postID = document.documentID as String?,
                        let postLocationCity = postData["locationCity"] as? String,
                        let postLocationState = postData["locationState"] as? String
                    {

                        let newPost = TrendingCellData(
                            author: postAuthor,
                            message: postMessage,
                            score: postScore,
                            timestamp: postTimestamp,
                            comments: postComments,
                            documentID: postID,
                            postLocationCity: postLocationCity,
                            postLocationState: postLocationState
                        )
                        
                        formattedTrendingPosts.formattedTrendingPostsArray.append(newPost)

                    }
                    
                }
                
                //Sorts array in chronological order
                formattedTrendingPosts.formattedTrendingPostsArray.sort { (lhs: TrendingCellData, rhs: TrendingCellData) -> Bool in
                    // you can have additional code here
                    return lhs.score ?? 0 > rhs.score ?? 0
                }

                
                DispatchQueue.main.async {
                    self.trendingTableView.reloadData()
                }

                self.lastTrendingFetchTimestamp = Date().timeIntervalSince1970
                                
            }
        }
    }

    
    //Handles functionality for cell selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellIndex = indexPath.row
        performSegue(withIdentifier: "trendingToComments", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let commentsVC = segue.destination as? CommentsViewController {
            
            commentsVC.postIndexInNearbyArray = selectedCellIndex
            commentsVC.modalPresentationCapturesStatusBarAppearance = true
            commentsVC.pathway = .trendingToComments
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formattedTrendingPosts.formattedTrendingPostsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let commentsCount: Int = Int(formattedTrendingPosts.formattedTrendingPostsArray[indexPath.row].comments?.count ?? 0)
        
        let trendingCellData = formattedTrendingPosts.formattedTrendingPostsArray[indexPath.row]
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingTableCell", for: indexPath) as! TrendingTableCell
        
        cell.authorLabel?.text = String(trendingCellData.author!) + " | " + (UserInfo.userCity ?? "") + ", " + (UserInfo.userState ?? "")
        cell.messageLabel?.text = String(trendingCellData.message!)
        cell.timestampLabel?.text = formatPostTime(postTimestamp: trendingCellData.timestamp!)
        cell.postScoreLabel?.text = String(trendingCellData.score!)
    
        if commentsCount > 1 {
            cell.commentLabel?.text = String(commentsCount) + " comments"
        } else if commentsCount == 1 {
            cell.commentLabel?.text = "1 comment"
        } else {
            cell.commentLabel?.text = ""
        }
    
        return cell
    }
    
    //Converts timestamp from 'seconds since 1970' to readable format
    func formatPostTime(postTimestamp: Double) -> String {
        
        let timeDifference = (UserInfo.refreshTime ?? 0.0) - postTimestamp
        
        let timeInMinutes = Int((timeDifference / 60.0))
        let timeInHours = Int(timeInMinutes / 60)
        let timeInDays = Int(timeInHours / 24)
        
        if timeInMinutes < 60 {
            return (String(timeInMinutes) + "m")
        } else if timeInMinutes >= 60 && timeInHours < 24 {
            return (String(timeInHours) + "h")
        } else {
            return (String(timeInDays) + "d")
        }
        
    
    }
    
    
    @IBAction func newPostButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "trendingToNewPost", sender: self)
    }
    

}
