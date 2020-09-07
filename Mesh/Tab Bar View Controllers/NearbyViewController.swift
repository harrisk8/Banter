//
//  NearbyViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/22/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase

class NearbyViewController: UIViewController, UITableViewDataSource {


    @IBOutlet weak var nearbyTableView: UITableView!
    
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        nearbyTableView.dataSource = self
        
        nearbyTableView.register(UINib(nibName: "NearbyTableViewCell", bundle: nil), forCellReuseIdentifier: "NearbyTableCellIdentifier")
        
        nearbyTableView.estimatedRowHeight = 150;
        nearbyTableView.rowHeight = UITableView.automaticDimension;
        
        nearbyTableView.layoutMargins = .zero
        nearbyTableView.separatorInset = .zero
        
        loadPostsFromDatabase()
        
        
    }
    
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
                        
                        DispatchQueue.main.async {
                            self.nearbyTableView.reloadData()
                            
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewdidappear")
        DispatchQueue.main.async {
            self.nearbyTableView.reloadData()
        }
        
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
        cell.timestampLabel?.text = String(nearbyCellData.timestamp! )
        
        return cell
        
    }

    
    
}


