//
//  NearbyViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/22/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase

class NearbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var nearbyTableView: UITableView!
    
    let database = Firestore.firestore()
    
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
        
        
    }
    
    //Reads posts from database and integrates into local array
    func loadPostsFromDatabase() {
        
        database.collection("posts").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print(err.localizedDescription)
            } else {
                
                for document in querySnapshot!.documents {
                    
                    let postData = document.data()
                    
                    if let postAuthor = postData["author"] as? String, let postMessage = postData["message"] as? String, let postTimestamp = postData["timestamp"] as? Double {
                        
                        let newPost = NearbyCellData(author: postAuthor, message: postMessage, timestamp: postTimestamp)
                        
                        NearbyArray.nearbyArray.append(newPost)
                        
                        print(self.formatPostTime(postTimestamp: postTimestamp))
                        
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
        print("viewdidappear")
        DispatchQueue.main.async {
            self.nearbyTableView.reloadData()
        }
        
    }
    
    
    @IBAction func newPostButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "navTopRightToNewPost", sender: self)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(NearbyArray.nearbyArray.count)
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
        
        let timeInMinutes = Int((timeDifference / 60.0))
        let timeInHours = Int(timeInMinutes / 60)
        let timeInDays = Int(timeInHours / 24)
        
        if timeInMinutes < 60 {
            return (String(timeInMinutes) + "m")
        } else if timeInMinutes >= 60 && timeInHours < 23 {
            return (String(timeInHours) + "h")
        } else {
            return (String(timeInDays) + "d")
        }
        
    
    }
    
    //Handles functionality for cell selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        print(NearbyArray.nearbyArray[indexPath.row])
    }

    
}


