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
import CoreLocation


class NearbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, refreshNearbyTable {
    
    @IBOutlet weak var nearbyTableView: UITableView!
    
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let database = Firestore.firestore()
    var locationManager = CLLocationManager()
    private let refreshControl = UIRefreshControl()
    
    var oldPostsFetchedFromCoreData: [NearbyPostsEntity]?
    var refreshArray: [NearbyCellData]?
    
    var newDataScanned = false
    var selectedCellIndex: Int?
    var lastContentOffset: CGFloat = 0
    
    var lastCoreDataTimestamp: Double?
    var timestampRefreshed: Double?
    var lastTimestampPulledFromServer = 0.0
    
    var oldNearbyPosts: [NearbyCellData] = []
    var newlyFetchedPosts: [NearbyCellData] = []
    var refreshFetchedPosts: [NearbyCellData] = []
        
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("User Appearance Name Last Set to:")
        print(UserDefaults.standard.string(forKey: "lastUserAppearanceName") ?? "")
                
        let userID = Auth.auth().currentUser!.uid
        UserInfo.userID = userID
        print(UserInfo.userID)
    
        locationManager.delegate = self
        
        //Checks if user has location enabled.
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
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
        
        UserInfo.userState = "FL"
        UserInfo.userCity = "Gainesville"
        UserInfo.userAppearanceName = "Harris"
        
//        testingUpdate()
        
        getUserDocID()

    }
    
    func testingUpdate() {
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let dataContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "NearbyPostsEntity")
        
        fetchRequest.predicate = NSPredicate(format: "documentID = %@", "ZIl5WzaDXWN3ASkNquRz")
        
        do {
            
            let test = try dataContext.fetch(fetchRequest)
            
            let objectUpdate = test as NSObject
            
            objectUpdate.setValue("NEWMESSAGE", forKey: "message")
            
            do {
                try dataContext.save()
            }
            catch {
                print(error)
            }
            
        }
        catch {
            print(error)
        }
        
    }
    
    
  
    //Reads posts from database and integrates into local array
    func loadPostsFromDatabase() {
        
        
        //Updates local timestamp of moment refreshed
        timestampRefreshed = Date().timeIntervalSince1970
        
        
        //Existing Post Load
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == true {
            
            print("EXISTING USER")
            
            UserInfo.userCollectionDocID = UserDefaults.standard.string(forKey: "userCollectionDocID")
            print("USERDOCID")
            print(UserInfo.userCollectionDocID)
            
            readLocalData()
            retrieveLastPostTimestamp()
                        
            if timestampRefreshed ?? 0 > lastCoreDataTimestamp ?? 0 {
                print("Checking database for new posts")
                fetchNewPosts()
            }
            
        }
        
        //New User Post Load, assumes locality has content
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == false {
            print("NEW USER")
            
            //TESTING PURPOSES ONLY - Assigns initial name
            UserInfo.userAppearanceName = "Harris"
            
            UserDefaults.standard.set(timestampRefreshed, forKey: "lastRefreshTimestamp")
            print(UserDefaults.standard.double(forKey: "lastRefreshTimestamp"))
            
            fetchAllPostsForLocality()
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
                        print("PULLED NEW DOC ID")
                        print(UserInfo.userCollectionDocID)
                        UserDefaults.standard.set(UserInfo.userCollectionDocID, forKey: "userCollectionDocID")
                    
                    }
                }

            }
        }
        
    }
        
        
    
    func readLocalData() {
            
        do {
            self.oldPostsFetchedFromCoreData = try dataContext.fetch(NearbyPostsEntity.fetchRequest())
        }
        catch {
            
        }
        
        //Grab array count of old posts fetched from Core Data
        let oldPostsArrayCount: Int = oldPostsFetchedFromCoreData?.count ?? 0
        print("Number of locally stored posts " + String(oldPostsArrayCount))
        
        if oldPostsArrayCount > 0 {
            
            for x in 0...(oldPostsArrayCount-1) {
        
                print("Core Data item: " + String(x))
                
                let coreDataCellData = NearbyCellData(
                    author: oldPostsFetchedFromCoreData?[x].author as String?,
                    message: oldPostsFetchedFromCoreData?[x].message as String?,
                    score: oldPostsFetchedFromCoreData?[x].score as Int32?,
                    timestamp: oldPostsFetchedFromCoreData?[x].timestamp as Double?,
                    comments: oldPostsFetchedFromCoreData?[x].comments as? [[String: AnyObject]],
                    documentID: oldPostsFetchedFromCoreData?[x].documentID as String?,
                    loadedFromCoreData: true,
                    userDocID: oldPostsFetchedFromCoreData?[x].userDocID as String?
                )
                
                //Add post pulled from Core Data to old posts array (intermediate array)
                self.oldNearbyPosts.append(coreDataCellData)
                print(coreDataCellData)
            }

        } else {
            print("No old posts, fetching all new")
        }

    }
    
    func addPostsToCoreData() {
        
        if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 1 {
            
            let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                        
            coreDataPostCell.author = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].author
            coreDataPostCell.comments = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].comments as NSArray?
            coreDataPostCell.documentID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].documentID
            coreDataPostCell.message = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].message
            coreDataPostCell.score = (newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].score as Int32?) ?? 0
            coreDataPostCell.timestamp = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp ?? 0.0
            coreDataPostCell.userDocID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].userDocID ?? ""
            
            
            print("Adding one new post to CoreData")
            
            do {
                try dataContext.save()
            }
            catch {
            }
            
        } else if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count > 1 {
            
            for x in 0...((newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count) - 1) {
                
                let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                            
                coreDataPostCell.author = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].author
                coreDataPostCell.comments = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].comments as NSArray?
                coreDataPostCell.documentID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].documentID
                coreDataPostCell.message = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].message
                coreDataPostCell.score = (newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].score as Int32?) ?? 0
                coreDataPostCell.timestamp = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].timestamp ?? 0.0
                coreDataPostCell.userDocID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].userDocID ?? ""

                
                print("Adding multiple posts to Core Data")
                
                do {
                    try dataContext.save()
                }
                catch {
                }
                
            }
        } else {
            print("No new posts to add to Core Data")
        }
        
                
    }
    
    
    
    
    //Fetches new posts after comparing previous timestamp to new timestamp (Existing users)
    func fetchNewPosts() {
        
        database.collection("posts")
            .whereField("timestamp", isGreaterThan: lastTimestampPulledFromServer)
            .whereField("locationCity", isEqualTo: UserInfo.userCity ?? "")
            .whereField("locationState", isEqualTo: UserInfo.userState ?? "")
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
                        let postUserDocID = postData["userDocID"] as? String
                    {
                        let newPost = NearbyCellData(
                            author: postAuthor,
                            message: postMessage,
                            score: postScore ?? 0,
                            timestamp: postTimestamp,
                            comments: postComments ?? nil,
                            documentID: postID,
                            loadedFromCoreData: false,
                            userDocID: postUserDocID
                            )
                        
                        newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.append(newPost)
                        
                    }
                    
                }
                
            }
                
                //Prevents app from crashing if there are no new posts to load
                if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 0 {
                    //No new posts
                    
                } else if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count != 0 {
                    self.lastTimestampPulledFromServer = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp ?? 0.0
                    UserDefaults.standard.set(self.lastTimestampPulledFromServer, forKey: "lastTimestampPulledFromServer")
                }
     
                print("Number of new posts: " + String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count))
                print("NEW Post")
                print(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray)
                self.addPostsToCoreData()
                self.organizeArrayForTableView()
        }
    }
    
    
    //Fetches all posts for user's location if user opens App for first time
    func fetchAllPostsForLocality() {
        
        database.collection("posts")
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
                            let postID = document.documentID as String?,
                            let postUserDocID = postData["userDocID"] as? String

                        {
                            let newPost = NearbyCellData(
                                author: postAuthor,
                                message: postMessage,
                                score: postScore ?? 0,
                                timestamp: postTimestamp,
                                comments: postComments ?? nil,
                                documentID: postID,
                                userDocID: postUserDocID
                            )
                            
                            newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.append(newPost)
                            
                        }
                    }
                    
                    //Sets lastTimestampPulledFromServer to 0 if user launches for first time in location with zero content
                    if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 0 {
                        self.lastTimestampPulledFromServer = 0.0
                        UserDefaults.standard.set(0.0, forKey: "lastTimestampPulledFromServer")
                    } else if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count != 0 {
                        self.lastTimestampPulledFromServer = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp ?? 0.0
                        UserDefaults.standard.set(self.lastTimestampPulledFromServer, forKey: "lastTimestampPulledFromServer")
                    }
                    
                    self.addPostsToCoreData()
                    self.organizeArrayForTableView()
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
    
    func retrieveLastPostTimestamp() {
        
//        formattedPosts.formattedPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
//            // you can have additional code here
//            return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
//        }
        
        if oldNearbyPosts.count > 0 {
            
            //Sorts array of old posts pulled from Core Data by timestamp
            oldNearbyPosts.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
                return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
            }
            
            lastCoreDataTimestamp = oldNearbyPosts[0].timestamp ?? 0
            
        } else {
            
            //Sets last timestamp to zero if Core Data is empty
            lastCoreDataTimestamp = 0.0
        }
        
        lastTimestampPulledFromServer = UserDefaults.standard.double(forKey: "lastTimestampPulledFromServer")
        
        
    }
    
    //Refreshes tableview after user returns to screen from new post
    override func viewDidAppear(_ animated: Bool) {
        
        lastTimestampPulledFromServer = UserDefaults.standard.double(forKey: "lastTimestampPulledFromServer")

        
        DispatchQueue.main.async {
            self.nearbyTableView.reloadData()
        }
        
    }
    
 
    
    @IBAction func newPostButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "navTopRightToNewPost", sender: self)
    }
    

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyPostsFinal.finalNearbyPostsArray.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nearbyCellData = nearbyPostsFinal.finalNearbyPostsArray[indexPath.row]
        
        let commentsCount: Int = Int(nearbyPostsFinal.finalNearbyPostsArray[indexPath.row].comments?.count ?? 0)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyTableCell", for: indexPath) as! NearbyTableCell
        cell.authorLabel?.text = String(nearbyCellData.author ?? "")
        cell.messageLabel?.text = String(nearbyCellData.message! )
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
        print(nearbyPostsFinal.finalNearbyPostsArray[indexPath.row])
        performSegue(withIdentifier: "postToComments", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let commentsVC = segue.destination as? CommentsViewController {
            
            commentsVC.postArrayPosition = selectedCellIndex
            commentsVC.modalPresentationCapturesStatusBarAppearance = true
            commentsVC.delegate = self
            
            if nearbyPostsFinal.finalNearbyPostsArray[selectedCellIndex ?? 0].loadedFromCoreData == false {
                //Post was newly loaded- no need to re-query database
                
                commentsVC.postLoadedFromCoreData = false
                
            } else {
                //Post was loaded from Core Data. Refresh with database query
                
                commentsVC.postLoadedFromCoreData = true
                
                //Prevents post from being redudantly updated if user opens again
                nearbyPostsFinal.finalNearbyPostsArray[selectedCellIndex ?? 0].loadedFromCoreData = false
                
            }
            
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
//                       UserInfo.userCity = firstLocation?.locality ?? ""
//                       UserInfo.userState = firstLocation?.administrativeArea ?? ""
                    
                        
                       self.loadPostsFromDatabase()
                        
                       
                   } else {
                    // An error occurred during geocoding.
                       completionHandler(nil)
                       print("ERROR")
                   }
                   
               })
           } else {
               // No location was available.
               completionHandler(nil)
               print("NON AVAIL")
            UserInfo.userCity = "Gainesville"
            UserInfo.userState = "FL"
            self.loadPostsFromDatabase()
           }
       }
    
    @objc func refreshedTableView() {
        refreshFetchedPosts = []
        checkNewPostsForRefresh()
        self.refreshControl.endRefreshing()
    }
    
    func checkNewPostsForRefresh() {
        
        print("Checking for new posts")
        
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
                    //Stores the latest timestamp of data pulled from server.
                    self.lastTimestampPulledFromServer = self.refreshFetchedPosts[0].timestamp ?? 0.0
                    
                    //Stores latest timestamp to user defaults
                    UserDefaults.standard.set(self.lastTimestampPulledFromServer, forKey: "lastTimestampPulledFromServer")
                }
                
                //Adds all posts from the intermediate refresh array to final nearby array
                nearbyPostsFinal.finalNearbyPostsArray.append(contentsOf: self.refreshFetchedPosts)
                
                //Sort by timestamp
                nearbyPostsFinal.finalNearbyPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
                    return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
                }
                
                DispatchQueue.main.async {
                    self.nearbyTableView.reloadData()
                }
                
                self.addPostsPulledFromRefreshToCoreData()
            }
        }
    }

    func addPostsPulledFromRefreshToCoreData() {
                
        if refreshFetchedPosts.count == 1 {
            
            let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                        
            coreDataPostCell.author = refreshFetchedPosts[0].author
            coreDataPostCell.comments = refreshFetchedPosts[0].comments as NSArray?
            coreDataPostCell.documentID = refreshFetchedPosts[0].documentID
            coreDataPostCell.message = refreshFetchedPosts[0].message
            coreDataPostCell.score = (refreshFetchedPosts[0].score as Int32?) ?? 0
            coreDataPostCell.timestamp = refreshFetchedPosts[0].timestamp ?? 0.0
            
            print("Adding one post from refresh to Core Data")
            
            do {
                try dataContext.save()
            }
            catch {
            }
            
        } else if refreshFetchedPosts.count > 1 {
            
            for x in 0...((refreshFetchedPosts.count) - 1) {
                
                let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                            
                coreDataPostCell.author = refreshFetchedPosts[x].author
                coreDataPostCell.comments = refreshFetchedPosts[x].comments as NSArray?
                coreDataPostCell.documentID = refreshFetchedPosts[x].documentID
                coreDataPostCell.message = refreshFetchedPosts[x].message
                coreDataPostCell.score = (refreshFetchedPosts[x].score as Int32?) ?? 0
                coreDataPostCell.timestamp = refreshFetchedPosts[x].timestamp ?? 0.0
                
                print("Adding multiple posts to Core Data")
                
                do {
                    try dataContext.save()
                }
                catch {
                }
                
            }
        } else {
            print("No new posts to add to Core Data")
        }
        
                
    }
    
    //Delegate method which is called when user closes comments VC, functionally updates comment counter on table cell
    func refreshtable() {
        DispatchQueue.main.async {
            self.nearbyTableView.reloadData()
        }
    }
    
    
    
    
}


