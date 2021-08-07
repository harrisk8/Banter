//
//  CommentsViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 9/13/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase
import CoreData
import FirebaseFirestore

protocol refreshLastVCTable {
    func refreshtable()
}

protocol adjustNearbyVote {
    func adjustVote()
}

class CommentsViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var screenView: UIView!
    @IBOutlet weak var postMessage: UITextView!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var commentsEditorView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var postCommentButton: UIButton!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentsTextViewBackground: UIView!
    
    @IBOutlet weak var messageBackground: UIView!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var dislikeButtonOLD: UIButton!
    @IBOutlet weak var likeButtonOLD: UIButton!
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let database = Firestore.firestore()
    var refreshLastVCTableDelegate: refreshLastVCTable?
    var voteDelegate: adjustNearbyVote?

    
    var viewTranslation = CGPoint(x: 0, y: 0)
    var lastContentOffset: CGFloat = 0
    
    var pointsScrolled = 0
    var keyboardHeight: Double?
    var screenWidth = UIScreen.main.bounds.width
    

    var commentData: [String: AnyObject]?
    var notificationData: [String: AnyObject]?
    
    var commentsArray: [[String: AnyObject]] = []
    
    var didFastSwipe = false
    

    var commentTimestamp: Double?
    
    var segueFromInbox = false
    
    var fetchPost = false
    
    var inboxPostArrayPosition: Int?
    
    var postIndexInNearbyArray: Int?
    var postIndexInTrendingArray: Int?

    var postLoadedFromCoreData: Bool?
    
    var newlyFetchedPost: NearbyCellData?


    var docID: String = ""
    
    var matchIndex: Int = 0
    
    //Stores like status only at local scope (current VC instance)
    var likedPost: Bool?
    var dislikedPost: Bool?
    
    var pathway: pathwayIntoComments?

    override func viewDidLoad() {

        overrideUserInterfaceStyle = .light
            
        super.viewDidLoad()
        
        postMessage.delegate = self
        
        setUpUI()
        
        processPathwayToComments()
        
//        print(" - - - - - Segue from Inbox Status: - - - - - - ")
//        print(segueFromInbox)
//
//        //Handles control flow if user enters VC from Nearby versus from Inbox
//        if segueFromInbox == false {
//
//            postMessage.text = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].message
//
//            commentsArray = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].comments ?? []
//
//            docID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].documentID ?? ""
//
//            if commentsArray.count == 0 {
//                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].comments = []
//            }
//
//            postInfoLabel.text = String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].author ?? "")
//
//            postInfoLabel.text? += " | "
//
//            postInfoLabel.text? += String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].locationState ?? "")
//
//
//            DispatchQueue.main.async {
//                self.commentsTableView.reloadData()
//            }
//        } else {
//            //Handles control flow if user proceeds from inbox
//
//            //Checks array of pulled notifications (first step, whole post) to see if it matches the notification doc ID
//            //If it does, then it will pull data to present in VC via the array itself
//
//            if NotificationArrayRaw.notificationArrayRaw.count == 1 && NotificationArrayRaw.notificationArrayRaw[0].documentID == NotificationArrayData.notificationArraySorted[inboxPostArrayPosition ?? 0].documentID {
//
//                postMessage.text = NotificationArrayRaw.notificationArrayRaw[0].message
//                commentsArray = NotificationArrayRaw.notificationArrayRaw[0].comments ?? []
//                docID = NotificationArrayRaw.notificationArrayRaw[0].documentID ?? ""
//
//
//                postInfoLabel.text? += String(NotificationArrayRaw.notificationArrayRaw[0].author ?? "")
//
//                postInfoLabel.text? += " | "
//                postInfoLabel.text? += String(NotificationArrayRaw.notificationArrayRaw[0].locationCity ?? "")
//
//                postInfoLabel.text? +=  ", "
//
//                postInfoLabel.text? += String(NotificationArrayRaw.notificationArrayRaw[0].locationState ?? "")
//
//                DispatchQueue.main.async {
//                    self.commentsTableView.reloadData()
//                }
//
//            } else if NotificationArrayRaw.notificationArrayRaw.count > 1 {
//
//                for x in (0...NotificationArrayRaw.notificationArrayRaw.count-1) {
//
//                    if NotificationArrayData.notificationArrayFinal[inboxPostArrayPosition ?? 0].documentID ==
//                        NotificationArrayRaw.notificationArrayRaw[x].documentID {
//
//                        print("Match")
//                        print(NotificationArrayData.notificationArraySorted[inboxPostArrayPosition ?? 0].documentID ?? "")
//                        print(NotificationArrayRaw.notificationArrayRaw[x].documentID ?? "")
//
//                        matchIndex = x
//                        fetchPost = false
//
//                        postMessage.text = NotificationArrayRaw.notificationArrayRaw[matchIndex].message
//                        commentsArray = NotificationArrayRaw.notificationArrayRaw[matchIndex].comments ?? []
//                        docID = NotificationArrayRaw.notificationArrayRaw[matchIndex].documentID ?? ""
//
//                        postInfoLabel.text? += String(NotificationArrayRaw.notificationArrayRaw[matchIndex].author ?? "")
//
//                        postInfoLabel.text? += " | "
//
//                        postInfoLabel.text? += String(NotificationArrayRaw.notificationArrayRaw[matchIndex].locationCity ?? "")
//
//                        postInfoLabel.text? += ", "
//
//                        postInfoLabel.text? += String(NotificationArrayRaw.notificationArrayRaw[matchIndex].locationState ?? "")
//
//                        DispatchQueue.main.async {
//                            self.commentsTableView.reloadData()
//                        }
//                    }
//
//                }
//
//            } else {
//
//                //the post must be pulled from firebase, then also merge with userPosts coredata
//                fetchPost = true
//                print("Fetch post data from notification from database)")
//                fetchPostData()
//
//
//            }
//        }
        
        print(" - - - - - COMMENT ARRAY COUNT - - - - ")
        print(commentsArray.count)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss))
        view.addGestureRecognizer(panRecognizer)
        panRecognizer.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(getKeyboardHeight(keyboardWillShowNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        

    }
    
    //The comments screen can be accessed either via nearby, trending, school, or inbox. This function designates the correct data flow depending on from which part of the app the user is viewing comments for.
    func processPathwayToComments() {
        
        switch pathway {
        
        case .nearbyToComments:
            print("User entering comments VC from Nearby")
            loadDataForNearbyPost()
            
        case .trendingToComments:
            print("User entering comments VC from Trending")
            loadDataForTrendingPost()

        case .inboxToComments:
            print("User entering comments VC from Nearby")
            loadDataForInboxPost()
            
        case .mySchoolToComments:
            print("User entering comments VC from Nearby")
            
        case .none:
            dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    func loadDataForNearbyPost() {
        
        postMessage.text = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].message
        commentsArray = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].comments ?? []
        docID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].documentID ?? ""
        likedPost = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].likedPost
        dislikedPost = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].dislikedPost
        
        postInfoLabel.text = String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].author ?? "")
        postInfoLabel.text? += " | "
        postInfoLabel.text? += String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].locationCity ?? "")
        postInfoLabel.text? += ", "
        postInfoLabel.text? += String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].locationState ?? "")
        
        authorLabel.text = String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].author ?? "")
        
        scoreLabel.text = String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score ?? 0)
        
        if commentsArray.count == 0 {
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].comments = []
        }
        
        //Configures logic for like/dislike button color depending on state
        if likedPost == true && dislikedPost == false {
            likeButton.setImage(UIImage(named: "Like Button Orange"), for: .normal)
            dislikeButton.setImage(UIImage(named: "Dislike Button Greyed Out"), for: .normal)

        } else if likedPost == false && dislikedPost == true {
            dislikeButton.setImage(UIImage(named: "Dislike Button Selected"), for: .normal)
            likeButton.setImage(UIImage(named: "Like Button Greyed Out"), for: .normal)
        } else {
            dislikeButton.setImage(UIImage(named: "Dislike Button White"), for: .normal)
            likeButton.setImage(UIImage(named: "Like Button White"), for: .normal)
        }
        
        DispatchQueue.main.async {
            self.commentsTableView.reloadData()
        }
        
    }
    
    func loadDataForSchoolPost() {
        
        postMessage.text = MySchoolPosts.MySchoolPostsArray[postIndexInNearbyArray ?? 0].message
        commentsArray = MySchoolPosts.MySchoolPostsArray[postIndexInNearbyArray ?? 0].comments ?? []
        docID = MySchoolPosts.MySchoolPostsArray[postIndexInNearbyArray ?? 0].documentID ?? ""
        likedPost = MySchoolPosts.MySchoolPostsArray[postIndexInNearbyArray ?? 0].likedPost
        dislikedPost = MySchoolPosts.MySchoolPostsArray[postIndexInNearbyArray ?? 0].dislikedPost
        
        postInfoLabel.text = String(MySchoolPosts.MySchoolPostsArray[postIndexInNearbyArray ?? 0].author ?? "")
        postInfoLabel.text? += " | "
        postInfoLabel.text? += String(MySchoolPosts.MySchoolPostsArray[postIndexInNearbyArray ?? 0].schoolName ?? "")
        
        authorLabel.text = String(MySchoolPosts.MySchoolPostsArray[postIndexInNearbyArray ?? 0].author ?? "")
        
        scoreLabel.text = String(MySchoolPosts.MySchoolPostsArray[postIndexInNearbyArray ?? 0].score ?? 0)
        
        if commentsArray.count == 0 {
            MySchoolPosts.MySchoolPostsArray[postIndexInNearbyArray ?? 0].comments = []
        }
        
        //Configures logic for like/dislike button color depending on state
        if likedPost == true && dislikedPost == false {
            likeButton.setImage(UIImage(named: "Like Button Orange"), for: .normal)
            dislikeButton.setImage(UIImage(named: "Dislike Button Greyed Out"), for: .normal)

        } else if likedPost == false && dislikedPost == true {
            dislikeButton.setImage(UIImage(named: "Dislike Button Selected"), for: .normal)
            likeButton.setImage(UIImage(named: "Like Button Greyed Out"), for: .normal)
        } else {
            dislikeButton.setImage(UIImage(named: "Dislike Button White"), for: .normal)
            likeButton.setImage(UIImage(named: "Like Button White"), for: .normal)
        }
        
        DispatchQueue.main.async {
            self.commentsTableView.reloadData()
        }
        
    }
    
    func loadDataForInboxPost() {
        
        //Handles control flow if user proceeds from inbox
        //Checks array of pulled notifications (first step, whole post) to see if it matches the notification doc ID
        //If it does, then it will pull data to present in VC via the array itself
        
        if NotificationWholePostArray.notificationWholePostArray.count == 1 && NotificationWholePostArray.notificationWholePostArray[0].documentID == NotificationArrayData.notificationArraySorted[inboxPostArrayPosition ?? 0].documentID {
            
            postMessage.text = NotificationWholePostArray.notificationWholePostArray[0].message
            commentsArray = NotificationWholePostArray.notificationWholePostArray[0].comments ?? []
            docID = NotificationWholePostArray.notificationWholePostArray[0].documentID ?? ""
            
            
            postInfoLabel.text? += String(NotificationWholePostArray.notificationWholePostArray[0].author ?? "")
            postInfoLabel.text? += " | "
            postInfoLabel.text? += String(NotificationWholePostArray.notificationWholePostArray[0].locationCity ?? "")
            postInfoLabel.text? +=  ", "
            postInfoLabel.text? += String(NotificationWholePostArray.notificationWholePostArray[0].locationState ?? "")
            
            DispatchQueue.main.async {
                self.commentsTableView.reloadData()
            }
            
        } else if NotificationWholePostArray.notificationWholePostArray.count > 1 {
            //Iterates through array of posts recently fetched for notification. If post being viewed matches one of the posts that is in the array, the data is pulled from there rather via Firebase.
            
            for x in (0...NotificationWholePostArray.notificationWholePostArray.count-1) {
                
                if NotificationArrayData.notificationArrayFinal[inboxPostArrayPosition ?? 0].documentID ==
                    NotificationWholePostArray.notificationWholePostArray[x].documentID {
                    
                    print("Match")
                    print(NotificationArrayData.notificationArraySorted[inboxPostArrayPosition ?? 0].documentID ?? "")
                    print(NotificationWholePostArray.notificationWholePostArray[x].documentID ?? "")
                    
                    matchIndex = x
                    fetchPost = false
                    
                    postMessage.text = NotificationWholePostArray.notificationWholePostArray[matchIndex].message
                    commentsArray = NotificationWholePostArray.notificationWholePostArray[matchIndex].comments ?? []
                    docID = NotificationWholePostArray.notificationWholePostArray[matchIndex].documentID ?? ""
                    
                    postInfoLabel.text? += String(NotificationWholePostArray.notificationWholePostArray[matchIndex].author ?? "")
                    
                    
                    postInfoLabel.text? += " | "
                    
                    postInfoLabel.text? += String(NotificationWholePostArray.notificationWholePostArray[matchIndex].locationCity ?? "")
                        
                    postInfoLabel.text? += ", "
                    
                    postInfoLabel.text? += String(NotificationWholePostArray.notificationWholePostArray[matchIndex].locationState ?? "")
                    
                    DispatchQueue.main.async {
                        self.commentsTableView.reloadData()
                    }
                }
                
            }
            
        }
    }
    
    func loadDataForTrendingPost() {
        
        postMessage.text = formattedTrendingPosts.formattedTrendingPostsArray[postIndexInNearbyArray ?? 0].message
        commentsArray = formattedTrendingPosts.formattedTrendingPostsArray[postIndexInNearbyArray ?? 0].comments ?? []
        docID = formattedTrendingPosts.formattedTrendingPostsArray[postIndexInNearbyArray ?? 0].documentID ?? ""
        likedPost = formattedTrendingPosts.formattedTrendingPostsArray[postIndexInNearbyArray ?? 0].likedPost
        dislikedPost = formattedTrendingPosts.formattedTrendingPostsArray[postIndexInNearbyArray ?? 0].dislikedPost
        
        postInfoLabel.text = String(formattedTrendingPosts.formattedTrendingPostsArray[postIndexInNearbyArray ?? 0].author ?? "")
        postInfoLabel.text? += " | "
        postInfoLabel.text? += String(formattedTrendingPosts.formattedTrendingPostsArray[postIndexInNearbyArray ?? 0].postLocationState ?? "")
        
        if commentsArray.count == 0 {
            formattedTrendingPosts.formattedTrendingPostsArray[postIndexInNearbyArray ?? 0].comments = []
        }
        
        DispatchQueue.main.async {
            self.commentsTableView.reloadData()
        }
        
        
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        
        switch pathway {
        
        case .nearbyToComments:
            print("Voting on post from Nearby")
            
            if dislikedPost == true && likedPost == false {
                //Removing dislike from already disliked post
                        
                print("Removing dislike from already disliked")
                //Updates score in master array
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score! += 1
                
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].likedPost = false
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].dislikedPost = false
                
                dislikeButton.setImage(UIImage(named: "Dislike Button White"), for: .normal)
                likeButton.setImage(UIImage(named: "Like Button White"), for: .normal)

                dislikedPost = false
                likedPost = false
                
                scoreLabel.text? = String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score!)
                
                voteDelegate?.adjustVote()
                        
            } else if likedPost == false && dislikedPost == false {
                //Adding like to post
                        
                print("Adding like")

                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score! += 1
                
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].likedPost = true
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].dislikedPost = false
                
                likeButton.setImage(UIImage(named: "Like Button Orange"), for: .normal)
                dislikeButton.setImage(UIImage(named: "Dislike Button Greyed Out"), for: .normal)
                
                likedPost = true
                dislikedPost = false

                scoreLabel.text? = String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score!)
                
                voteDelegate?.adjustVote()

                        
            } else if likedPost == true && dislikedPost == false {
                //Removing like from already liked post
                        
                print("Removing like from already liked")

                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score! -= 1
                
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].likedPost = false
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].dislikedPost = false
                
                dislikeButton.setImage(UIImage(named: "Dislike Button White"), for: .normal)
                likeButton.setImage(UIImage(named: "Like Button White"), for: .normal)
                
                //Updates vote state for the current instance of the comments VC
                likedPost = false
                dislikedPost = false
                
                scoreLabel.text? = String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score!)
                
                
                voteDelegate?.adjustVote()
            }
        
        case .trendingToComments:
            print("Voting on post from Trending")
            
            if dislikedPost == true && likedPost == false {
                //Removing dislike from already disliked post
                        
                //Updates score in master array
                formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].score! += 1
                
                formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].dislikedPost = false
                formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].likedPost = false
                
                dislikeButton.setImage(UIImage(named: "Dislike Button White"), for: .normal)
                likeButton.setImage(UIImage(named: "Like Button White"), for: .normal)

                dislikedPost = false
                likedPost = false
                
                scoreLabel.text? = String(formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].score!)
                
                voteDelegate?.adjustVote()
                        
            } else if likedPost == false && dislikedPost == false {
                //Adding like to post
                        
                formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].score! += 1
                
                formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].likedPost = true
                formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].dislikedPost = false
                
                likeButton.setImage(UIImage(named: "Like Button Orange"), for: .normal)
                dislikeButton.setImage(UIImage(named: "Dislike Button Greyed Out"), for: .normal)
                
                likedPost = true
                dislikedPost = false

                scoreLabel.text? = String(formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].score!)
                
                voteDelegate?.adjustVote()

                        
            } else if likedPost == true && dislikedPost == false {
                //Removing like from already liked post
                        
                formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].score! -= 1
                
                formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].likedPost = false
                formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].dislikedPost = false
                
                dislikeButton.setImage(UIImage(named: "Dislike Button White"), for: .normal)
                likeButton.setImage(UIImage(named: "Like Button White"), for: .normal)
                
                //Updates vote state for the current instance of the comments VC
                likedPost = false
                dislikedPost = false
                
                
                scoreLabel.text? = String(formattedTrendingPosts.formattedTrendingPostsArray[postIndexInTrendingArray ?? 0].score!)
                
                
                voteDelegate?.adjustVote()
            }
            
            

        case .inboxToComments:
            print("Voting on post from Nearby")
            
        case .mySchoolToComments:
            print("Voting on post from my school")

            
        case .none:
            dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
    
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        
        switch pathway {
        
        case .nearbyToComments:
            print("Voting on post from Nearby")
            
            if dislikedPost == true && likedPost == false {
                //Removing dislike from already disliked post
                        
                //Updates score in master array
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score! += 1
                
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].likedPost = false
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].dislikedPost = false
                
                dislikeButton.setImage(UIImage(named: "Dislike Button White"), for: .normal)
                likeButton.setImage(UIImage(named: "Like Button White"), for: .normal)

                dislikedPost = false
                likedPost = false
                
                scoreLabel.text? = String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score!)
                
                voteDelegate?.adjustVote()
                        
            } else if likedPost == false && dislikedPost == false {
                //Adding dislike to post
                        
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score! -= 1
                
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].likedPost = false
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].dislikedPost = true
                
                likeButton.setImage(UIImage(named: "Like Button Greyed Out"), for: .normal)
                dislikeButton.setImage(UIImage(named: "Dislike Button Selected"), for: .normal)
                
                likedPost = false
                dislikedPost = true

                scoreLabel.text? = String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score!)
                
                voteDelegate?.adjustVote()

                        
            } else if likedPost == true && dislikedPost == false {
                //Removing like from already liked post
                        
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score! -= 1
                
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].likedPost = false
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].dislikedPost = false
                
                dislikeButton.setImage(UIImage(named: "Dislike Button White"), for: .normal)
                likeButton.setImage(UIImage(named: "Like Button White"), for: .normal)
                
                //Updates vote state for the current instance of the comments VC
                likedPost = false
                dislikedPost = false
                
                
                
                scoreLabel.text? = String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].score!)
                
                
                voteDelegate?.adjustVote()
            }
        
        case .trendingToComments:
            print("Voting on post from Trending")
            
            

        case .inboxToComments:
            print("Voting on post from Nearby")
            
        case .mySchoolToComments:
            print("Voting on post from my school")

            
        case .none:
            dismiss(animated: true, completion: nil)
            
        }
        
        
    
    }
    

    func fetchPostData() {
        
        print("trying to get doc)")
        
        let docRef = database.collection("posts").document(NotificationArrayData.notificationArrayFinal[inboxPostArrayPosition ?? 0].documentID ?? "")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                
                let postData = document.data()
                
                if let postAuthor = postData?["author"] as? String,
                    let postMessage = postData?["message"] as? String,
                    let postScore = postData?["score"] as? Int32?,
                    let postTimestamp = postData?["timestamp"] as? Double,
                    let postComments = postData?["comments"] as? [[String: AnyObject]]?,
                    let postDocumentID = document.documentID as String?,
                    let postUserDocID = postData?["userDocID"] as? String,
                    let postlocationCity = postData?["locationCity"] as? String,
                    let postLocationState = postData?["locationState"] as? String
                    
                {

                    let newPost = NearbyCellData(
                        author: postAuthor,
                        message: postMessage,
                        score: postScore,
                        timestamp: postTimestamp,
                        comments: postComments,
                        documentID: postDocumentID,
                        userDocID: postUserDocID,
                        locationCity: postlocationCity,
                        locationState: postLocationState)

                    self.newlyFetchedPost = newPost
                    
                    self.postMessage.text = self.newlyFetchedPost?.message
                    self.commentsArray = self.newlyFetchedPost?.comments ?? []
                    self.docID = self.newlyFetchedPost?.documentID ?? ""
                    
                    
                    var postInfoString = self.newlyFetchedPost?.author ?? ""
                    
                    postInfoString += " | "
                    

                    print(" - - - DATA FETCHED FROM FIREBASE - - - - -")
                    print(self.newlyFetchedPost)

                    DispatchQueue.main.async {
                        self.commentsTableView.reloadData()
                    }
                    
                }
            } else {
                print("Document does not exist")
            }
        }

    }
    
    @IBAction func postCommentPressed(_ sender: Any) {
        
        //Slides comment editor up if post button pressed while editor is down
        if commentsTextView.isFirstResponder == false {
            commentsTextView.becomeFirstResponder()

        } else if commentsTextView.text != "" && commentsTextView.isFirstResponder == true {
            
            commentTimestamp = Date().timeIntervalSince1970
            
            commentData = ["author" : UserInfo.userAppearanceName as AnyObject,
                           "message" : commentsTextView.text as AnyObject,
                           "commentTimestamp" : commentTimestamp as AnyObject,
                           "userDocID" : UserInfo.userCollectionDocID as AnyObject
            ]
            
            notificationData = ["author": UserInfo.userAppearanceName as AnyObject,
                                "message" : commentsTextView.text as AnyObject,
                                "notificationTimestamp" : commentTimestamp as AnyObject,
                                "documentID": docID as AnyObject
            ]
            
            writeCommentToDatabase()
            
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postIndexInNearbyArray ?? 0].comments?.append(commentData!)
            
            //Create function to update coredata
            
            commentsArray.append(commentData!)
            print(commentsArray.count)
            
            DispatchQueue.main.async {
                self.commentsTableView.reloadData()
            }
            
            commentsTextView.resignFirstResponder()
            slideCommentEditorDown()
            
            print("CommentsArray content:")
            print(commentsArray)
            

            
        }
        
        refreshLastVCTableDelegate?.refreshtable()

    }
    
    @IBAction func userTappedCommentEditor(_ sender: Any) {
        print("editor area has been tapped.")
        commentsTextView.becomeFirstResponder()
        //        slideCommentEditorUp()
    }
    
    
    
    //Changes status bar text to black to contrast against white background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.darkContent
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "commentsToReport", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let reportVC = segue.destination as? ReportPostViewController {
            
            reportVC.postArrayPosition = postIndexInNearbyArray
            
        }
    }
    
    
    
    //Detects if user taps table during editing process
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tap")
        print(indexPath.row)
        
        if commentsTextView.isFirstResponder == true {
            commentsTextView.resignFirstResponder()
            slideCommentEditorDown()
            
        }
        
        commentsTableView.deselectRow(at: indexPath, animated: false)
        print("deselect")
    }

    func writeCommentToDatabase() {
        
        print(docID)
        
        let databaseRef = database.collection("posts").document(docID)

        databaseRef.updateData([

            "comments": FieldValue.arrayUnion([commentData as Any]),
            "lastCommentTimestamp": commentTimestamp ?? 0.0,
            "notifications": FieldValue.arrayUnion([notificationData as Any])
            
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("Document successfully written")
            }
        }
        
    }
    
    
    func setUpUI() {
        
        if likedPost == true && dislikedPost == false {
            print("is a liked post")
        } else {
            print("is a disliked post")
        }
        
        postMessage.layer.cornerRadius = 17.5
        
        commentsEditorView.translatesAutoresizingMaskIntoConstraints = true
        commentsTextView.translatesAutoresizingMaskIntoConstraints = true
        commentsTextViewBackground.translatesAutoresizingMaskIntoConstraints = true
        
        
        commentsEditorView.layer.shadowOpacity = 0.4
        commentsEditorView.layer.shadowRadius = 3.5
        commentsEditorView.layer.shadowColor = UIColor.black.cgColor
        commentsEditorView.layer.masksToBounds = true
        commentsEditorView.layer.shadowOffset = (CGSize(width: 0.0, height: 1.0))
        commentsEditorView.layer.cornerRadius = 17.5
        commentsEditorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        commentsEditorView.clipsToBounds = true
        
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.register(UINib(nibName: "NearbyTableCell", bundle: nil), forCellReuseIdentifier: "NearbyTableCell")
        commentsTableView.estimatedRowHeight = 150;
        commentsTableView.rowHeight = UITableView.automaticDimension;
        commentsTableView.layoutMargins = .zero
        commentsTableView.separatorInset = .zero
        
        commentsTextView.delegate = self
        commentsTextView.layer.cornerRadius = 10
        commentsTextView.clipsToBounds = true
        
        commentsTextViewBackground.clipsToBounds = true
        commentsTextViewBackground.layer.cornerRadius = 12
        
//        commentsTextViewBackground.layer.shadowOpacity = 0.4
//        commentsTextViewBackground.layer.shadowRadius = 3.5
//        commentsTextViewBackground.layer.shadowColor = UIColor.black.cgColor
//        commentsTextViewBackground.layer.shadowOffset = (CGSize(width: 0.0, height: 0.0))
//        commentsTextViewBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        postMessage.layer.cornerRadius = 17.5
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.messageBackground.frame
        rectShape.position = self.messageBackground.center
        rectShape.path = UIBezierPath(roundedRect: self.messageBackground.bounds, byRoundingCorners: [.bottomLeft , .bottomRight , .topLeft], cornerRadii: CGSize(width: 25, height: 25)).cgPath

        self.messageBackground.layer.backgroundColor = UIColor(red: 113/255, green: 62/255, blue: 248/255, alpha: 1).cgColor
        //Here I'm masking the textView's layer with rectShape layer
        self.messageBackground.layer.mask = rectShape

        
    }
    
    
    //Slides comment editor view up over table view
    func textViewDidBeginEditing(_ textView: UITextView) {
        slideCommentEditorUp()
        commentsTextView.text = ""
    }
    
    override func viewDidLayoutSubviews() {
//        commentsTextView.centerVerticalText()
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        refreshLastVCTableDelegate?.refreshtable()
        dismiss(animated: true, completion: nil)
    }
    
    //Determines number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if segueFromInbox == false {
//
//            return commentsArray.count
//
//        } else if segueFromInbox == true {
//
//            if fetchPost == false {
//
//                print(commentsArray.count)
//                return (commentsArray.count)
//
//            } else {
//                return newlyFetchedPost?.comments?.count ?? 0
//            }
//
//
//        }
            
            
        return commentsArray.count
        
    }
    
    //Populates table cells with data from array
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyTableCell", for: indexPath) as! NearbyTableCell
        
        
//        if indexPath.row == (nearbyPostsFinal.finalNearbyPostsArray[postArrayPosition ?? 0].comments?.count ?? 0) {
//
//            print("GO")
//
//            cell.authorLabel?.text = "testcell"
//            cell.messageLabel?.text = "testcell"
//            cell.timestampLabel?.text = "testcell"
//
//            return cell
//        }
        
        let nearbyCellData = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[indexPath.row]
        
        let commentsCount: Int = Int(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[indexPath.row].comments?.count ?? 0)
        
        
        cell.authorLabel?.text = commentsArray[indexPath.row]["author"] as? String
        cell.messageLabel?.text = commentsArray[indexPath.row]["message"] as? String
        cell.timestampLabel?.text = formatPostTime(postTimestamp: commentsArray[indexPath.row]["commentTimestamp"] as? Double ?? 0.0)
        cell.commentLabel?.text = ""
        cell.likeButton.isUserInteractionEnabled = false
        cell.likeButton.alpha = 0
        cell.postScoreLabel.text = ""
        cell.dislikeButton.isUserInteractionEnabled = false
        cell.dislikeButton.alpha = 0
        cell.contentView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        return cell
        
    }
    
    //Slides comment text view editor up as keyboard slides up
    func slideCommentEditorUp() {
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, animations: {
                self.commentsEditorView.frame.origin.y -= CGFloat(self.keyboardHeight ?? 0)
            })
        }
        
    }
    
    //Slides comment text view down after post or dismissal swipe
    func slideCommentEditorDown() {
        
        pointsScrolled = 0
        UIView.animate(withDuration: 0.2) {
            self.commentsEditorView.frame.origin.y += CGFloat(self.keyboardHeight ?? 0)
    
        }
    
    }

    
    //Converts timestamp from 'seconds since 1970' to readable format
    func formatPostTime(postTimestamp: Double) -> String {
        
        let timeDifference = Date().timeIntervalSince1970 - postTimestamp
        
        print(timeDifference)
        
        var timeInMinutes = Int((timeDifference / 60.0))
        let timeInHours = Int(timeInMinutes / 60)
        let timeInDays = Int(timeInHours / 24)
        
        if timeInMinutes < 1 {
            timeInMinutes = 1
        }
        
        if timeInMinutes < 60 {
            return (String(timeInMinutes) + "m")
        } else if timeInMinutes >= 60 && timeInHours < 23 {
            return (String(timeInHours) + "h")
        } else {
            return (String(timeInDays) + "d")
        }
    }
    
    //This delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = commentsTableView.contentOffset.y
        pointsScrolled = 0
    }

    //Handles scroll detection
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                
        if self.lastContentOffset < commentsTableView.contentOffset.y {
            
            //User Scrolled Down
        
        } else if self.lastContentOffset > commentsTableView.contentOffset.y  {
            //User Scrolled Up
            
            pointsScrolled += 1
            print(pointsScrolled)
            
            //Resigns editor if user scrolls up >100pts with editor open
            if pointsScrolled >= 100 && commentsTextView.isFirstResponder == true {
                slideCommentEditorDown()
                self.commentsTextView.resignFirstResponder()
            }
            
        } else {
            //No scroll
            
        }
    }
    
    //Enables functionality to slide screen over previous VC during back-swipe
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
                
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        let velocity = sender.velocity(in: view)
        
        switch sender.state {
            
        //Handles functionality during pan (user finger has NOT left screen)
        case .changed:

            viewTranslation = sender.translation(in: view)

            //Detects downward swipe during editing comment
            if viewTranslation.y > 20 && commentsTextView.isFirstResponder == true {
                print("DOWNSWIPE")
                commentsTextView.resignFirstResponder()
                slideCommentEditorDown()
            }

            //Prevents VC from sliding to the left and allows screen to follow finger
            if viewTranslation.x > 0 && velocity.x <= 1750 {
                
                DispatchQueue.main.async {
                                        
                    UIView.animate(withDuration: 0.025, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.view.frame.origin.x = CGFloat(self.viewTranslation.x)
                    })

                }
            }
            
        //Handles functionality after pan (user finger HAS LEFT screen)
        case .ended:
        
            if velocity.x > 1250 {
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.view.frame.origin.x = CGFloat(self.screenWidth)
                    }, completion: { [weak self] _ in
                        self?.commentsTextView.resignFirstResponder()
                        self?.slideCommentEditorDown()
                        self?.refreshLastVCTableDelegate?.refreshtable()
                        self?.dismiss(animated: false, completion: nil)
                    })
                }
            }
            
            if velocity.x <= 1250 {
                                
                DispatchQueue.main.async {

                    UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.view.frame.origin.x = CGFloat(0)
                    })
                }
            }
                    
            
        default:
            break
        }
        
    }
    


    
    //Obtains height of keyboard allowing for view-sliding functionality for keyboard pop-up.
    @objc func getKeyboardHeight(keyboardWillShowNotification notification: Notification) {
        if let userInfo = notification.userInfo,
        let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = Double(keyboardSize.height)
            NotificationCenter.default.removeObserver(self)
        }
        print(keyboardHeight!)
    }
    
    
}

extension UITextView {

    func centerVerticalText() {
        self.textAlignment = .center
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}
