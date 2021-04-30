//
//  ReportPostViewController.swift
//  Banter
//
//  Created by Harris Kapoor on 4/29/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore


class ReportPostViewController: UIViewController {
    
    var postArrayPosition: Int?
    
    let database = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        writeReportedPostToDatabase()
    }
    
    
    
    func writeReportedPostToDatabase() {
                        
        var ref: DocumentReference? = nil

        ref = database.collection("reported posts").addDocument(data: [
                        
            "author": newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postArrayPosition ?? 0].author,
            "userDocID": newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postArrayPosition ?? 0].userDocID,
            "locationCity": "Gainesville",
            "locationState": "FL",
            "message": newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postArrayPosition ?? 0].message,
            "timestamp": newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postArrayPosition ?? 0].timestamp,
            "documentID" : newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postArrayPosition ?? 0].documentID,
            "reported by": UserInfo.userCollectionDocID
        
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("Post successfully reported")
                print(ref?.documentID ?? "")

            }
        }
        
    }
    


}
