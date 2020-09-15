//
//  TrendingViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 9/14/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class TrendingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
    @IBOutlet weak var trendingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trendingTableView.dataSource = self
        trendingTableView.delegate = self
        
        trendingTableView.register(UINib(nibName: "TestTableViewCell", bundle: nil), forCellReuseIdentifier: "TestCell")
        
        trendingTableView.estimatedRowHeight = 150;
        trendingTableView.rowHeight = UITableView.automaticDimension;
        
        trendingTableView.layoutMargins = .zero
        trendingTableView.separatorInset = .zero
        


    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(NearbyArray.nearbyArray.count)
        return NearbyArray.nearbyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let nearbyCellData = NearbyArray.nearbyArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as! TestTableViewCell
        cell.authorLabel?.text = String(nearbyCellData.author!) + " - " + (UserInfo.userCity ?? "Gainesville") + ", " + (UserInfo.userState ?? "FL")
        cell.messageLabel?.text = String(nearbyCellData.message!)
//        cell.locationLabel?.text = String(UserInfo.userCity!) + ", " + String(UserInfo.userState!)
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

}
