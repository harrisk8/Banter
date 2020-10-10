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
    
    var testArray: [NearbyCellData]?
    var locallyStoredNearbyPosts: [NearbyPostsEntity]?
    var refreshArray: [NearbyCellData]?
    
    var localDataScanned = false
    var newDataScanned = false
    var selectedCellIndex: Int?
    var lastContentOffset: CGFloat = 0
    
    var lastPostTimestamp: Double?
    var previousTimestamp: Double?
    var timestampRefreshed: Double?
    
    var oldNearbyPosts: [NearbyCellData] = []
    var newlyFetchedPosts: [NearbyCellData]?
        
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        let userID = Auth.auth().currentUser!.uid
        UserInfo.userID = userID
    
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
        
//        testingUpdate()

    }
    
    func testingUpdate() {
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let dataContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "NearbyPostsEntity")
        
        fetchRequest.predicate = NSPredicate(format: "documentID = %@", "ZIl5WzaDXWN3ASkNquRz")
        
        do {
            
            let test = try dataContext.fetch(fetchRequest)
            
            let objectUpdate = test as! NSManagedObject
            
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
        print(timestampRefreshed ?? 0)

        
        //Existing Post Load
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == true {
            
            print("EXISTING USER")
            
            readLocalData()
            retrieveLastPostTimestamp()
            
            //Fetch last timestamp refreshed and update new refresh timestamp
            previousTimestamp = UserDefaults.standard.double(forKey: "lastRefreshTimestamp")
            UserDefaults.standard.set(timestampRefreshed, forKey: "lastRefreshTimestamp")
            
//            print("Timestamp Refreshed")
//            print(timestampRefreshed ?? 0)
//            print("Previous refresh")
//            print(previousTimestamp ?? 0)
//            print("New refresh timestamp stored")
//            print(UserDefaults.standard.double(forKey: "lastRefreshTimestamp"))

            
            if timestampRefreshed ?? 0 > lastPostTimestamp ?? 0 {
                print("Checking database for new posts")
                fetchNewPosts()
            }
            
        }
        
        //New User Post Load, assumes locality has content
        if UserDefaults.standard.bool(forKey: "userLaunchedBefore") == false {
            print("NEW USER")
            
            UserDefaults.standard.set(timestampRefreshed, forKey: "lastRefreshTimestamp")
            print(UserDefaults.standard.double(forKey: "lastRefreshTimestamp"))
            
            fetchAllPostsForLocality()
            organizeArrayForTableView()

        }
        
    }
    
    func readLocalData() {
            
        do {
            self.locallyStoredNearbyPosts = try dataContext.fetch(NearbyPostsEntity.fetchRequest())
        }
        catch {
            
        }
        
        let arrayCount: Int = locallyStoredNearbyPosts?.count ?? 0
        print("Number of locally stored posts " + String(arrayCount))
        
        if arrayCount > 0 && localDataScanned == false {
            
            for x in 0...(arrayCount-1) {
        
                print("Core Data item: " + String(x))
                
                let coreDataCellData = NearbyCellData(
                    author: locallyStoredNearbyPosts?[x].author as String?,
                    message: locallyStoredNearbyPosts?[x].message as String?,
                    score: locallyStoredNearbyPosts?[x].score as Int32?,
                    timestamp: locallyStoredNearbyPosts?[x].timestamp as Double?,
                    comments: locallyStoredNearbyPosts?[x].comments as? [[String: AnyObject]],
                    documentID: locallyStoredNearbyPosts?[x].documentID as String?,
                    loadedFromCoreData: true
                )
                
                self.oldNearbyPosts.append(coreDataCellData)
                print("OLD POST")
                print(coreDataCellData)
            }
            
            self.oldNearbyPosts.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
                // you can have additional code here
                return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
            }
            
            lastPostTimestamp = oldNearbyPosts[0].timestamp
            
            
            

        } else {
            print("No old posts, fetching all new")
        }

        
    }
    
    func addPostsToCoreData() {
        
        if NearbyArray.newlyFetchedNearbyPosts.count == 1 {
            
            let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                        
            coreDataPostCell.author = NearbyArray.newlyFetchedNearbyPosts[0].author
            coreDataPostCell.comments = NearbyArray.newlyFetchedNearbyPosts[0].comments as NSArray?
            coreDataPostCell.documentID = NearbyArray.newlyFetchedNearbyPosts[0].documentID
            coreDataPostCell.message = NearbyArray.newlyFetchedNearbyPosts[0].message
            coreDataPostCell.score = (NearbyArray.newlyFetchedNearbyPosts[0].score as Int32?) ?? 0
            coreDataPostCell.timestamp = NearbyArray.newlyFetchedNearbyPosts[0].timestamp ?? 0.0
            
            print("Adding one new post to CoreData")
            
            do {
                try dataContext.save()
            }
            catch {
            }
            
        } else if NearbyArray.newlyFetchedNearbyPosts.count > 1 {
            
            for x in 0...((NearbyArray.newlyFetchedNearbyPosts.count) - 1) {
                
                let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                            
                coreDataPostCell.author = NearbyArray.newlyFetchedNearbyPosts[x].author
                coreDataPostCell.comments = NearbyArray.newlyFetchedNearbyPosts[x].comments as NSArray?
                coreDataPostCell.documentID = NearbyArray.newlyFetchedNearbyPosts[x].documentID
                coreDataPostCell.message = NearbyArray.newlyFetchedNearbyPosts[x].message
                coreDataPostCell.score = (NearbyArray.newlyFetchedNearbyPosts[x].score as Int32?) ?? 0
                coreDataPostCell.timestamp = NearbyArray.newlyFetchedNearbyPosts[x].timestamp ?? 0.0
                
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
            .whereField("timestamp", isGreaterThan: lastPostTimestamp!)
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
                        let postID = document.documentID as String?
                    {
                        let newPost = NearbyCellData(
                            author: postAuthor,
                            message: postMessage,
                            score: postScore ?? 0,
                            timestamp: postTimestamp,
                            comments: postComments ?? nil,
                            documentID: postID,
                            loadedFromCoreData: false                        )
                        
                        NearbyArray.newlyFetchedNearbyPosts.append(newPost)
                        
                    }
                    
                }
                
            }
                
                print("NEW CONTENT")
                print(NearbyArray.newlyFetchedNearbyPosts.count)
                print(NearbyArray.newlyFetchedNearbyPosts)
                self.addPostsToCoreData()
                self.organizeArrayForTableView()
        }
    }
    
    
    //Fetches all posts for user's location if no existing Core Data content is detected.
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
                            
                            NearbyArray.newlyFetchedNearbyPosts.append(newPost)
                            
 
                        }
                    }
                    
                    self.addPostsToCoreData()
                    self.organizeArrayForTableView()

                }
        

            }
        
        
    }
    
    func organizeArrayForTableView() {
        
        print("Organizing array for Table View")
        formattedPosts.formattedPostsArray.append(contentsOf: NearbyArray.newlyFetchedNearbyPosts)
        
        if oldNearbyPosts.count != 0 {
            formattedPosts.formattedPostsArray.append(contentsOf: oldNearbyPosts)
        }
        
        formattedPosts.formattedPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
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
        
        oldNearbyPosts.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
            // you can have additional code here
            return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
        }
        
        if oldNearbyPosts.count ?? 0 > 0 {
            
            lastPostTimestamp = oldNearbyPosts[0].timestamp ?? 0
            print(lastPostTimestamp ?? 0.0)
            
        } else {
            
            lastPostTimestamp = 0.0
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
        return formattedPosts.formattedPostsArray.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nearbyCellData = formattedPosts.formattedPostsArray[indexPath.row]
        
        let commentsCount: Int = Int(formattedPosts.formattedPostsArray[indexPath.row].comments?.count ?? 0)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyTableCell", for: indexPath) as! NearbyTableCell
        cell.authorLabel?.text = String(nearbyCellData.author! )
        cell.messageLabel?.text = String(nearbyCellData.message! )
        cell.timestampLabel?.text = formatPostTime(postTimestamp: nearbyCellData.timestamp!)
        cell.postScoreLabel?.text = String(nearbyCellData.score!)
        
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
        print(formattedPosts.formattedPostsArray[indexPath.row])
        performSegue(withIdentifier: "postToComments", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let commentsVC = segue.destination as? CommentsViewController {
            
            commentsVC.postArrayPosition = selectedCellIndex
            commentsVC.modalPresentationCapturesStatusBarAppearance = true
            commentsVC.delegate = self
            
            if formattedPosts.formattedPostsArray[selectedCellIndex ?? 0].loadedFromCoreData == false {
                //Post was newly loaded- no need to re-query database
                
                commentsVC.postLoadedFromCoreData = false
                
            } else {
                //Post was loaded from Core Data. Refresh with database query
                
                commentsVC.postLoadedFromCoreData = true
                
                //Prevents post from being redudantly updated if user opens again
                formattedPosts.formattedPostsArray[selectedCellIndex ?? 0].loadedFromCoreData = false
                
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
                       UserInfo.userCity = firstLocation?.locality ?? ""
                       UserInfo.userState = firstLocation?.administrativeArea ?? ""
                    
                        
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
        checkNewPostsForRefresh()
        self.refreshControl.endRefreshing()
    }
    
    func checkNewPostsForRefresh() {
        
        database.collection("posts")
            .whereField("timestamp", isGreaterThan: formattedPosts.formattedPostsArray[0].timestamp ?? 0)
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
                        formattedPosts.formattedPostsArray.insert(newPost, at: 0)
                        
                    }
                }
                
                formattedPosts.formattedPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
                    // you can have additional code here
                    return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
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
    
    
    
    
}


