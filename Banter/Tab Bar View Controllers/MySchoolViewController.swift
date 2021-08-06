//
//  MySchoolViewController.swift
//  Banter
//
//  Created by Harris Kapoor on 8/2/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import UIKit
import Firebase

class MySchoolViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, cellVotingDelegate {
    
    @IBOutlet weak var addMySchoolButton: UIButton!
    @IBOutlet weak var mySchoolIconText: UIImageView!
    @IBOutlet weak var mySchoolTableView: UITableView!
    
    let database = Firestore.firestore()
    
    private let refreshControl = UIRefreshControl()
    
    var lastTimestampPulledFromServer: Double?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        switch UserInfo.hasUserAddedSchool {
        
        case .userHasAddedSchool:
            //Present table view of user's school's posts
            print("User has added school")
            
            //Configures UI to show table view and fetches 'My School' posts from Firebase
            userHasNotAddedSchoolSetup()
            fetchMySchoolPosts()
            
        case .userHasNotAddedSchool:
            //Present user with prompt and button to add school
            print("User has not added school")
            mySchoolTableView.isHidden = true
            
            userHasNotAddedSchoolSetup()



        case .none:
            //Present user with prompt and button to add school
            print("User has not added school")
            mySchoolTableView.isHidden = true

        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("APPEARED FROM UNWIND")
        //Configure UI to display school
    }
    
    
    //Configures UI for user that HAS added their school. This will disable the "Add my school" button in the interface and hide the prompt/button, while presenting the table view of posts near the user's school.
    func userHadAddedSchoolSetup() {
        
        addMySchoolButton.isUserInteractionEnabled = false
        addMySchoolButton.isHidden = true
        mySchoolIconText.isHidden = true
        
        mySchoolTableView.dataSource = self
        mySchoolTableView.delegate = self
        mySchoolTableView.register(UINib(nibName: "NearbyTableCell", bundle: nil), forCellReuseIdentifier: "NearbyTableCell")
        mySchoolTableView.estimatedRowHeight = 150;
        mySchoolTableView.rowHeight = UITableView.automaticDimension;
        mySchoolTableView.layoutMargins = .zero
        mySchoolTableView.separatorInset = .zero
        mySchoolTableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshedTableView), for: .valueChanged)
        
    }
    
    //Configures UI for user that HAS NOT added their school. This will disable/set alpha of table view to 0, while presenting button and prompt for the user to add their school.
    func userHasNotAddedSchoolSetup() {
        
        addMySchoolButton.isUserInteractionEnabled = true
        addMySchoolButton.isHidden = false
        mySchoolIconText.isHidden = false
        
    }
    
    @objc func refreshedTableView() {
        self.refreshControl.endRefreshing()
    }
    

    //Segues to school selection VC when button pressed
    @IBAction func addMySchoolButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "mySchoolToAddMySchool", sender: self)
    }
    
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MySchoolPosts.MySchoolPostsArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mySchoolCellData = MySchoolPosts.MySchoolPostsArray[indexPath.row]
        
        let commentsCount: Int = Int(MySchoolPosts.MySchoolPostsArray[indexPath.row].comments?.count ?? 0)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyTableCell", for: indexPath) as! NearbyTableCell
        
        cell.delegate = self
        
        //Configures data for cell
        cell.authorLabel?.text = String(mySchoolCellData.author ?? "")
        cell.messageLabel?.text = String(mySchoolCellData.message!)
        cell.timestampLabel?.text = formatPostTime(postTimestamp: mySchoolCellData.timestamp!)
        cell.postScoreLabel?.text = String(mySchoolCellData.score ?? 0)
        cell.likedPost = mySchoolCellData.likedPost ?? false
        cell.dislikedPost = mySchoolCellData.dislikedPost ?? false
        
        
        //Configures logic for like/dislike button color depending on state
        if cell.likedPost == true && cell.dislikedPost == false {
            cell.likeButton.setImage(UIImage(named: "Like Button Orange"), for: .normal)
            cell.dislikeButton.setImage(UIImage(named: "Dislike Button Greyed Out"), for: .normal)

        } else if cell.likedPost == false && cell.dislikedPost == true {
            cell.dislikeButton.setImage(UIImage(named: "Dislike Button Light Purple"), for: .normal)
            cell.likeButton.setImage(UIImage(named: "Like Button Greyed Out"), for: .normal)
        } else {
            cell.dislikeButton.setImage(UIImage(named: "Dislike Button Regular"), for: .normal)
            cell.likeButton.setImage(UIImage(named: "Like Button Regular"), for: .normal)
        }


        
        

        if commentsCount > 1 {
            cell.commentLabel?.text = String(commentsCount) + " comments"
        } else if commentsCount == 1 {
            cell.commentLabel?.text = "1 comment"
        } else {
            cell.commentLabel?.text = ""
        }
        
        return cell
        
        
    }
    
    func fetchMySchoolPosts() {
        
        print("Checking for new posts")
        
        if MySchoolPosts.MySchoolPostsArray.count == 0 {
            lastTimestampPulledFromServer = 0.0
        } else {
            lastTimestampPulledFromServer = MySchoolPosts.MySchoolPostsArray[0].timestamp ?? 0.0
        }
        
        database.collection("posts")
            .whereField("userSchool", isEqualTo: UserInfo.userSchool ?? "")
            .limit(to: 20)
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
                        let postID = document.documentID as String?,
                        let postUserDocID = postData["userDocID"] as? String,
                        let postSchoolName = postData["schoolName"] as? String
                    {
                        
                        let newPost = MySchoolCellData(
                            author: postAuthor,
                            message: postMessage,
                            score: postScore,
                            timestamp: postTimestamp,
                            comments: postComments ?? nil,
                            documentID: postID,
                            userDocID: postUserDocID,
                            schoolName: postSchoolName,
                            likedPost: false,
                            dislikedPost: false
                        )
                        
                        print(newPost)
                        
                        MySchoolPosts.MySchoolPostsArray.append(newPost)
                        

                    }
                    
                    //Stores the latest timestamp of data pulled from server.
                    self.lastTimestampPulledFromServer = MySchoolPosts.MySchoolPostsArray[0].timestamp ?? 0.0
                    
                    //Stores latest timestamp to user defaults
                    UserDefaults.standard.set(self.lastTimestampPulledFromServer, forKey: "lastTimestampPulledFromServer")
                    
                    
                }
                
                MySchoolPosts.MySchoolPostsArray.sort { (lhs: MySchoolCellData, rhs: MySchoolCellData) -> Bool in
                    return lhs.timestamp ?? 0 > rhs.timestamp ?? 0 }
                
                DispatchQueue.main.async {
                    self.mySchoolTableView.reloadData()
                }
                
            }
        }
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
        } else if timeInMinutes >= 60 && timeInHours < 24 {
            return (String(timeInHours) + "h")
        } else {
            return (String(timeInDays) + "d")
        }
        
    
    }
    
    func userPressedVoteButton(_ cell: NearbyTableCell, _ caseType: voteType) {
        <#code#>
    }

}

