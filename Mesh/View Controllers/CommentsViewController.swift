//
//  CommentsViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 9/13/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import QuartzCore

class CommentsViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var screenView: UIView!
    
    @IBOutlet weak var postMessage: UITextView!
    @IBOutlet weak var commentsTextView: UITextView!
    
    
    
    @IBOutlet weak var commentsEditorView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    
    @IBOutlet weak var commentsTableView: UITableView!
    
    var lastContentOffset: CGFloat = 0
    
    var pointsScrolled = 0

    
    var postArrayPosition: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postMessage.text = NearbyArray.nearbyArray[postArrayPosition ?? 0].message

        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        
        commentsTableView.register(UINib(nibName: "NearbyTableViewCell", bundle: nil), forCellReuseIdentifier: "NearbyTableCellIdentifier")
        
        commentsTableView.estimatedRowHeight = 150;
        commentsTableView.rowHeight = UITableView.automaticDimension;
        
        commentsTableView.layoutMargins = .zero
        commentsTableView.separatorInset = .zero
        
        commentsTextView.delegate = self
        commentsTextView.backgroundColor = UIColor.white
        commentsTextView.layer.cornerRadius = 5.0
        commentsTextView.clipsToBounds = true

    }
    
    func slideCommentEditorUp() {
        
        UIView.animate(withDuration: 0.3) {
            self.commentsEditorView.frame.origin.y -= CGFloat(UserInfo.keyboardHeight ?? 0) + CGFloat(self.commentsTextView.frame.height)
        }
    
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("GO")
        slideCommentEditorUp()
    }
    
    
    @IBAction func userSwipesBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = commentsTableView.contentOffset.y
    }
    
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.lastContentOffset < commentsTableView.contentOffset.y {
            // did move up
            print("SCROLLED DOWN")
        } else if self.lastContentOffset > commentsTableView.contentOffset.y  {
            // did move down
            pointsScrolled += 1
            if pointsScrolled >= 25 {
                
                UIView.animate(withDuration: 0.3) {
                    self.commentsEditorView.frame.origin.y += CGFloat(UserInfo.keyboardHeight ?? 0) + CGFloat(self.commentsTextView.frame.height)
                    self.commentsTextView.resignFirstResponder()

                }
                
                
            }
            print(pointsScrolled)
        } else {
            // didn't move
        }
    }
}
