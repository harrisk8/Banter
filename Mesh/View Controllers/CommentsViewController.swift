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
    
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    var lastContentOffset: CGFloat = 0
    var pointsScrolled = 0
    var postArrayPosition: Int?
    
    var keyboardHeight: Double?
    
    
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
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))

        NotificationCenter.default.addObserver(self, selector: #selector(getKeyboardHeight(keyboardWillShowNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("GO")
        slideCommentEditorUp()
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
    
    //Slides comment text view editor up as keyboard slides up
    func slideCommentEditorUp() {
        
        self.commentsEditorView.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.3) {
            self.commentsEditorView.frame.origin.y -= CGFloat(self.keyboardHeight ?? 0)
        }
    
    }
    
    func slideCommentEditorDown() {
        
     UIView.animate(withDuration: 0.3) {
        self.commentsEditorView.frame.origin.y += CGFloat(self.keyboardHeight ?? 0)
    
     }
    
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
    
    
    //This delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = commentsTableView.contentOffset.y
        print("Scroll")
    }

    //Handles scroll detection
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                
        if self.lastContentOffset < commentsTableView.contentOffset.y {
            
            //User Scrolled Down
            
            
        } else if self.lastContentOffset > commentsTableView.contentOffset.y  {
            
            //User Scrolled Up
            
            pointsScrolled += 1
            
            if pointsScrolled >= 50 {
                
                self.commentsTextView.resignFirstResponder()
                
                slideCommentEditorDown()
                
                pointsScrolled = 0


                
                
            }
            
        } else {
            // didn't move
        }
        
    }
    
    //Enables functionality to slide screen over previous VC during back-swipe
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.transform = CGAffineTransform(translationX: self.viewTranslation.x, y: 0)
            })
            
        case .ended:
            if viewTranslation.x < 200 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveLinear, animations: {
                self.view.transform = .identity
            })
        } else {
                performSegue(withIdentifier: "unwindCommentsToNearby", sender: self)
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
