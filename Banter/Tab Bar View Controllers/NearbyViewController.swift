//
//  NearbyViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/22/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import CoreData
import CoreLocation


class NearbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, refreshNearbyTable, cellVotingDelegate, updateNavBarLabel, updateNearbyChangeNameButton {
    
    
    func updateChangeNameButtonTitle() {
        print("NEARBY VC - Updating upper right label with current name")
        incognitoButton.title = UserDefaults.standard.string(forKey: "lastUserAppearanceName")
        
    
    }
    
    
 
    
    
    func updateNavButtonLabel() {
        print("Nav Delegate recieved")
    }
    
    
    @IBOutlet weak var nearbyTableView: UITableView!
    
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let database = Firestore.firestore()
    var locationManager = CLLocationManager()
    private let refreshControl = UIRefreshControl()
    
    var oldPostsFetchedFromCoreData: [NearbyPostsEntity]?
    var refreshArray: [NearbyCellData]?
    
    @IBOutlet weak var incognitoButton: UIBarButtonItem!
    
    var newDataScanned = false
    var selectedCellIndex: Int?
    var lastContentOffset: CGFloat = 0
    
    var timestampRefreshed: Double?
    var lastTimestampPulledFromServer = 0.0
    
    var oldNearbyPosts: [NearbyCellData] = []
    var newlyFetchedPosts: [NearbyCellData] = []
    var refreshFetchedPosts: [NearbyCellData] = []
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserDocID()
        
        configureUpperRightButton()
        
        AppearAsViewController.updateNearbyChangeNameButtonTitleDelegate = self
        
    
        locationManager.delegate = self
        
        //Checks if user has location enabled.
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            //Location enabled. Continue to grab location and load view.
            lookUpCurrentLocation(completionHandler: {_ in
            })
            
        } else {
            //Prompt user to enable location, after continue to load view
            setupLocationManager()
        }
        
        overrideUserInterfaceStyle = .light
        UserInfo.refreshTime = Date().timeIntervalSince1970
        
        nearbyTableView.dataSource = self
        nearbyTableView.delegate = self
        nearbyTableView.register(UINib(nibName: "NearbyTableCell", bundle: nil), forCellReuseIdentifier: "NearbyTableCell")
        nearbyTableView.estimatedRowHeight = 150;
        nearbyTableView.rowHeight = UITableView.automaticDimension;
        nearbyTableView.layoutMargins = .zero
        nearbyTableView.separatorInset = .zero
        nearbyTableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshedTableView), for: .valueChanged)
        
        
                
        UserDefaults.standard.set(true, forKey: "userLaunchedBefore")

        setUpPersistence()

        
    }
    
    @IBAction func currentNameButtonPressed(_ sender: Any) {
        
        print("User tapped name")
        
        performSegue(withIdentifier: "nearbyToChangeName", sender: self)
        
        
        
    }
    
    func configureUpperRightButton() {
        
        print("User Appearance Name Last Set to:")
        print(UserDefaults.standard.string(forKey: "lastUserAppearanceName") ?? "")
        
        //Handles contingency of first time start up- no value for lastUserAppearanceName yet so it is set to Incognito
        if UserDefaults.standard.string(forKey: "lastUserAppearanceName") == "" {
            UserDefaults.standard.set("Incognito", forKey: "lastUserAppearanceName")
            incognitoButton.title = "Incognito"
            UserDefaults.standard.setValue(true, forKey: "incognitoSelected")
        } else {
            print(UserDefaults.standard.string(forKey: "lastUserAppearanceName"))
        }
                
        if UserDefaults.standard.value(forKey: "incognitoSelected") as? Bool == true {
            incognitoButton.title = "Incognito"
        } else if UserDefaults.standard.value(forKey: "firstNameSelected") as? Bool == true {
            incognitoButton.title = UserDefaults.standard.value(forKey: "userFirstName") as? String
        } else if UserDefaults.standard.value(forKey: "nicknameSelected") as? Bool == true {
            incognitoButton.title = UserDefaults.standard.value(forKey: "userNickname") as? String

        }
        
    }
    
    func setUpPersistence() {
        
        //Existing Post Load
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == true {
            
            print(" - - - - - EXISTING USER - - - - - - ")
            
            
            UserInfo.userCollectionDocID = UserDefaults.standard.string(forKey: "userCollectionDocID")
            
            print(" - - - - - - User document ID - - - - - ")
            print(UserInfo.userCollectionDocID)
            
            
        }
        
        //New User Post Load, assumes locality has content
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == false {
            
            print(" - - - - - - NEW USER - - - - - - ")
            
            
            UserDefaults.standard.set(true, forKey: "userLaunchedBefore")
            
            //Sets lastCommentTimestamp to 0 when user launches for first time, used for notif
            UserDefaults.standard.set(0, forKey: "lastCommentTimestamp")
            
        }
        
    }
    
    func fetchNearbyPosts() {
        
        timestampRefreshed = Date().timeIntervalSince1970
        
        database.collection("posts")
            .whereField("locationCity", isEqualTo: UserInfo.userCity ?? "")
            .whereField("locationState", isEqualTo: UserInfo.userState ?? "")
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
                            let postDocumentID = document.documentID as String?,
                            let postUserDocID = postData["userDocID"] as? String,
                            let postlocationCity = postData["locationCity"] as? String?,
                            let postLocationState = postData["locationState"] as? String
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
                                locationState: postLocationState,
                                likedPost: false,
                                dislikedPost: false
                            )
                            
                        
                            
                            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.append(newPost)

                        }
                        
                    }
                    
                    if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 0 {
                        
                        print("- - - - - - NO NEARBY POSTS - - - - - - ")
                        
                    } else {
                        
                        newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
                            return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
                        }
                        
                        if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count != 0 {
                            self.lastTimestampPulledFromServer = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp ?? 0
                        } else {
                            self.lastTimestampPulledFromServer = 0.0
                        }
                        
                        DispatchQueue.main.async {
                            self.nearbyTableView.reloadData()
                        }
                        
                    }
                   
                }
        }
    }
    
  
    //Reads posts from database and integrates into local array
    func loadPostsFromDatabase() {
        
        //Updates local timestamp of moment refreshed
        timestampRefreshed = Date().timeIntervalSince1970
        
        //Existing Post Load
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == true {
            
            print(" - - - - - EXISTING USER - - - - - - ")
            
            UserInfo.userCollectionDocID = UserDefaults.standard.string(forKey: "userCollectionDocID")
            
            print(" - - - - - - User document ID - - - - - ")
            print(UserInfo.userCollectionDocID)
            
            
        }
        

        
        
        //New User Post Load, assumes locality has content
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == false {
            print(" - - - - - - NEW USER - - - - - - ")
            
            //TESTING PURPOSES ONLY - Assigns initial name
            UserInfo.userAppearanceName = "Name"
            
            UserDefaults.standard.set(timestampRefreshed, forKey: "lastRefreshTimestamp")
            print(UserDefaults.standard.double(forKey: "lastRefreshTimestamp"))
            
            //Sets lastCommentTimestamp to 0 when user launches for first time, used for notif
            UserDefaults.standard.set(0, forKey: "lastCommentTimestamp")
            
            organizeArrayForTableView()

        }
        
    }
    
    func getUserDocID() {
        
        database.collection("users")
            .whereField("userID", isEqualTo: UserInfo.userID ?? "")
        .getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print(err.localizedDescription)
            } else {
                
                for document in querySnapshot!.documents {
                    
                    let postData = document.data()
                    
                    if let postID = document.documentID as String? {
                        
                        UserInfo.userCollectionDocID = postID
                        print("The user's doc ID fetched below:")
                        print(UserInfo.userCollectionDocID)
                        UserDefaults.standard.set(UserInfo.userCollectionDocID, forKey: "userCollectionDocID")
                    
                    }
                }

            }
        }
        
    }
    
    
    func organizeArrayForTableView() {
        
        print("Organizing array for Table View")
        //Adds newly fetched posts to the formatted array        
        if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count != 0 {
            nearbyPostsFinal.finalNearbyPostsArray.append(contentsOf: newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray)
        }
        
        //Adds old posts pulled from Core Data to the formatted array
        if oldNearbyPosts.count != 0 {
            nearbyPostsFinal.finalNearbyPostsArray.append(contentsOf: oldNearbyPosts)
        }
        
        nearbyPostsFinal.finalNearbyPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
            // you can have additional code here
            return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
        }
        
        DispatchQueue.main.async {
            self.nearbyTableView.reloadData()
        }
        
    }
    
    
    //Refreshes tableview after user returns to screen from new post
    override func viewDidAppear(_ animated: Bool) {
        
        lastTimestampPulledFromServer = UserDefaults.standard.double(forKey: "lastTimestampPulledFromServer")
        
        incognitoButton.title = UserDefaults.standard.value(forKey: "lastUserAppearanceName") as? String

        
        DispatchQueue.main.async {
            self.nearbyTableView.reloadData()
        }
        
    }
    
 
    
    @IBAction func newPostButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "navTopRightToNewPost", sender: self)
    }
    

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nearbyCellData = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[indexPath.row]
        
        let commentsCount: Int = Int(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[indexPath.row].comments?.count ?? 0)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyTableCell", for: indexPath) as! NearbyTableCell
        
        cell.delegate = self
        
        cell.authorLabel?.text = String(nearbyCellData.author ?? "")
        cell.messageLabel?.text = String(nearbyCellData.message!)
        cell.timestampLabel?.text = formatPostTime(postTimestamp: nearbyCellData.timestamp!)
        cell.postScoreLabel?.text = String(nearbyCellData.score ?? 0)
        

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
    
    //Handles functionality for cell selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellIndex = indexPath.row
        performSegue(withIdentifier: "postToComments", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let commentsVC = segue.destination as? CommentsViewController {
            
            commentsVC.postIndexInNearbyArray = selectedCellIndex
            commentsVC.modalPresentationCapturesStatusBarAppearance = true
            commentsVC.delegate = self
            commentsVC.pathway = .nearbyToComments
            
        }
        
    }
    
    
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = nearbyTableView.contentOffset.y
    }
    
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            print(" you reached end of the table")
        }
        
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
    
    func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
       }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationHandler()
    }

    func locationHandler() {

        if CLLocationManager.locationServicesEnabled() == true {

            if (CLLocationManager.authorizationStatus() == .denied) {
                // The user denied authorization
                print("LOCATION SERVICES: DENIED")

            } else if (CLLocationManager.authorizationStatus() == .notDetermined) {
                // The user not determiend authorization
                print("LOCATION SERVICES: UNKNOWN")

            } else if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
                print("LOCATION SERVICES: AUTHORIZED")
                lookUpCurrentLocation(completionHandler: {_ in
                    })

            } else {
                   print("Please enable location in settings")
            }
            
               
        } else {
            //Access to user location permission denied!
            print("LOCATIONERROR")
        }
    }
       
       func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
           // Use the last reported location.
           if let lastLocation = self.locationManager.location {
               let geocoder = CLGeocoder()
                   
               // Look up the location and pass it to the completion handler
               geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                   
                   if error == nil {
                       let firstLocation = placemarks?[0]
                       completionHandler(firstLocation)
                       
                       print((firstLocation?.locality ?? "") + (firstLocation?.administrativeArea ?? ""))
                    
                    
                       UserInfo.userCity = firstLocation?.locality ?? ""
                       UserInfo.userState = firstLocation?.administrativeArea ?? ""
                        
                       self.fetchNearbyPosts()
                        
                       
                   } else {
                    
                    // An error occurred during geocoding.
                       completionHandler(nil)
                       print("ERROR")
                   }
                   
               })
            
           } else {
            
            // No location was available.
            completionHandler(nil)
            print("No location available")
            UserInfo.userCity = "Gainesville"
            UserInfo.userState = "FL"
           }
       }
    
    @objc func refreshedTableView() {
        refreshFetchedPosts = []
        checkNewPostsForRefresh()
        self.refreshControl.endRefreshing()
    }
    
    func checkNewPostsForRefresh() {
        
        print("Checking for new posts")
//        a5
        
        if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 0 {
            lastTimestampPulledFromServer = 0.0
        } else {
            lastTimestampPulledFromServer = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp ?? 0.0
        }
        
        database.collection("posts")
            .whereField("timestamp", isGreaterThan: lastTimestampPulledFromServer)
            .whereField("locationCity", isEqualTo: UserInfo.userCity ?? "")
            .whereField("locationState", isEqualTo: UserInfo.userState ?? "")
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
                        
                        print(newPost)
                        
                        //Appends new post to intermediate refresh array
                        self.refreshFetchedPosts.insert(newPost, at: 0)
                        
                    }
                }
                
                //Updates lastTimestampPulledFromServer only if new post is fetched
                if self.refreshFetchedPosts.count != 0 {
                    
                    //Adds all posts from the intermediate refresh array to final nearby array
                    newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.append(contentsOf: self.refreshFetchedPosts)
                    
                    //Sort by timestamp
                    newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
                        return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
                    }
                    
                    //Stores the latest timestamp of data pulled from server.
                    self.lastTimestampPulledFromServer = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp ?? 0.0
                    
                    //Stores latest timestamp to user defaults
                    UserDefaults.standard.set(self.lastTimestampPulledFromServer, forKey: "lastTimestampPulledFromServer")
                    
                    
                } else {
                    print(" - - - - - - REFRESH: There are no new posts - - - - - ")
                }
                
                DispatchQueue.main.async {
                    self.nearbyTableView.reloadData()
                }
                
            }
        }
    }

    
    //Delegate method which is called when user closes comments VC, functionally updates comment counter on table cell
    func refreshtable() {
        DispatchQueue.main.async {
            self.nearbyTableView.reloadData()
        }
    }
    
    func userPressedVoteButton(_ cell: NearbyTableCell, _ caseType: voteType) {
        
        //Extract and format array index for cell that was interacted with
        let voteIndexPath = self.nearbyTableView.indexPath(for: cell)
        let voteIndexPathRow = (voteIndexPath?[1] ?? 0)
        
        
        let assignVoteStatusToArray = caseType
        
        switch assignVoteStatusToArray {
            
        case .like:
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].likedPost = true
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].dislikedPost = false
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].score! += 1
            print("POST LIKED")
            DispatchQueue.main.async {
                self.nearbyTableView.reloadData()
            }
        case .dislike:
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].dislikedPost = true
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].likedPost = false
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].score! -= 1
            print("POST DISLIKED")
            DispatchQueue.main.async {
                self.nearbyTableView.reloadData()
            }
        case .removeLike:
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].dislikedPost = false
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].likedPost = false
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].score! -= 1
            print("POST UNLIKED")
            DispatchQueue.main.async {
                self.nearbyTableView.reloadData()
            }
        case .removeDislike:
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].dislikedPost = false
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].likedPost = false
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].score! += 1
            print("POST UNDISLIKED")
            DispatchQueue.main.async {
                self.nearbyTableView.reloadData()
            }
        case .dislikeFromLike:
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].dislikedPost = false
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].likedPost = false
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].score! -= 1
            print("POST DISLIKED FROM LIKED")
            DispatchQueue.main.async {
                self.nearbyTableView.reloadData()
            }
        case .likeFromDislike:
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].dislikedPost = false
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].likedPost = false
            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[voteIndexPathRow].score! += 1
            print("POST LIKED FROM DISLIKED")
            DispatchQueue.main.async {
                self.nearbyTableView.reloadData()
            }
        }
        
        let vote = VotingModel()
        vote.sendVoteToDatabase(postPositionInArray: voteIndexPathRow,  voteType: caseType)
    }
    
}


