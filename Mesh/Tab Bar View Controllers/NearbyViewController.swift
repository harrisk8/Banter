//
//  NearbyViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/22/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class NearbyViewController: UIViewController, UITableViewDataSource {


    @IBOutlet weak var nearbyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        nearbyTableView.dataSource = self
        
        nearbyTableView.register(UINib(nibName: "NearbyTableViewCell", bundle: nil), forCellReuseIdentifier: "NearbyTableCellIdentifier")
        
        nearbyTableView.estimatedRowHeight = 150;
        nearbyTableView.rowHeight = UITableView.automaticDimension;
        
        nearbyTableView.layoutMargins = .zero
        nearbyTableView.separatorInset = .zero
        
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(NearbyArray.nearbyArray.count)
        return NearbyArray.nearbyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nearbyCellData = NearbyArray.nearbyArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyTableCellIdentifier", for: indexPath) as! NearbyTableViewCell
        cell.authorLabel.text = String(nearbyCellData.author!)
        cell.messageLabel.text = String(nearbyCellData.message!)
        
        return cell
        
    }

    
    
}


