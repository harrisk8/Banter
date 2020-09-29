//
//  CommentsViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 9/13/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase

class CommentsViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var screenView: UIView!
    @IBOutlet weak var postMessage: UITextView!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var commentsEditorView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var postCommentButton: UIButton!
    @IBOutlet weak var commentsTableView: UITableView!
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    var lastContentOffset: CGFloat = 0
    var pointsScrolled = 0
    var postArrayPosition: Int?
    var keyboardHeight: Double?
    var screenWidth = UIScreen.main.bounds.width
    
    let database = Firestore.firestore()
    
    var commentData: [String: AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
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
        
        commentsEditorView.layer.cornerRadius = 20.0
        commentsEditorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss))

        view.addGestureRecognizer(panRecognizer)
        
        panRecognizer.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(getKeyboardHeight(keyboardWillShowNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
    }
    
    
    
    @IBAction func postCommentPressed(_ sender: Any) {
        if commentsTextView.text != "" {
            commentData = ["author" : UserInfo.userAppearanceName as AnyObject, "message" : commentsTextView.text as AnyObject]
            
            
            writeCommentToDatabase()
            
            NearbyArray.nearbyArray[postArrayPosition ?? 0].comments?.append(commentData!)
            DispatchQueue.main.async {
                self.commentsTableView.reloadData()
            }
            
            commentsTextView.resignFirstResponder()
            slideCommentEditorDown()
            
            
            
        }
    }
    
    
    func writeCommentToDatabase() {
        
        let docID: String = NearbyArray.nearbyArray[postArrayPosition ?? 0].documentID ?? ""
        print(docID)
        
        let databaseRef = database.collection("posts").document(docID)


        databaseRef.updateData([

            "comments": FieldValue.arrayUnion([commentData!])

        ]) { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("Document successfully written")
            }
        }
        
        
        
    }
    
    
    //Slides comment editor view up over table view
    func textViewDidBeginEditing(_ textView: UITextView) {
        slideCommentEditorUp()
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    //Determines number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ARRAY TOTAL")
        print(NearbyArray.nearbyArray.count)
        print(NearbyArray.nearbyArray[postArrayPosition ?? 0].comments?.count ?? 0)
        return (NearbyArray.nearbyArray[postArrayPosition ?? 0].comments?.count ?? 0) + 1
    }
    
    //Populates table cells with data from array
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let nearbyCellData = NearbyArray.nearbyArray[postArrayPosition ?? 0].comments?[indexPath.row]
        
        print("cell it")
        print(indexPath.row)
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyTableCellIdentifier", for: indexPath) as! NearbyTableViewCell
        
        
        if indexPath.row == (NearbyArray.nearbyArray[postArrayPosition ?? 0].comments?.count ?? 0) {
            print("GO")
            
            cell.authorLabel?.text = "testcell"
            cell.messageLabel?.text = "testcell"
            cell.timestampLabel?.text = "testcell"
            
            return cell
        }
        
        
        cell.authorLabel?.text = NearbyArray.nearbyArray[postArrayPosition ?? 0].comments?[indexPath.row]["author"] as? String
        
        
        cell.messageLabel?.text = NearbyArray.nearbyArray[postArrayPosition ?? 0].comments?[indexPath.row]["message"] as? String
        cell.timestampLabel?.text = "5"
        
        return cell
        
    }
    
    //Slides comment text view editor up as keyboard slides up
    func slideCommentEditorUp() {
        
        self.commentsEditorView.translatesAutoresizingMaskIntoConstraints = true

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, animations: {
            self.commentsEditorView.frame.origin.y -= CGFloat(self.keyboardHeight ?? 0)
        })
        
    }
    
    //Slides comment text view down after post or dismissal swipe
    func slideCommentEditorDown() {
        
        pointsScrolled = 0
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
            
            if pointsScrolled >= 100 && commentsTextView.isFirstResponder == true {
                
                slideCommentEditorDown()
                self.commentsTextView.resignFirstResponder()

                
            }
            
        } else {
            //No scroll
        }
    }
    
    //Enables functionality to slide screen over previous VC during back-swipe
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        
        let velocity = sender.velocity(in: view)
        
        switch sender.state {
            
            
        //Handles functionality during pan (user finger has NOT left screen)
        case .changed:
            
            viewTranslation = sender.translation(in: view)

            //Detects downward swipe during edit
            if viewTranslation.y > 20 && commentsTextView.isFirstResponder == true {
                print("DOWNSWIPE")
                commentsTextView.resignFirstResponder()
                slideCommentEditorDown()
            }
            
            
            //Detects swipe after some pan
            if viewTranslation.x > (screenWidth * 0.4) && velocity.x > 1000 {
                
                UIView.animate(withDuration: 1) {
                    self.view.transform = CGAffineTransform(translationX: -self.screenWidth, y: 0)
                }
                dismiss(animated: true, completion: nil)
                
            }
            
            //Detects a "swipe-like" gesture to dismiss VC
            if velocity.x > 1350 {
                
                UIView.animate(withDuration: 1) {
                    self.view.transform = CGAffineTransform(translationX: -self.screenWidth, y: 0)
                }
                dismiss(animated: true, completion: nil)
            }
            

            //Dismisses VC if user slides VC past 0.6 times screen width to the right
            if viewTranslation.x > (screenWidth * 0.6) {
        
                UIView.animate(withDuration: 0.1) {
                    self.view.transform = CGAffineTransform(translationX: -self.screenWidth, y: 0)
                }
                dismiss(animated: true, completion: nil)
            }
                    
            //Prevents VC from sliding to the left
            if viewTranslation.x > 0 {
                UIView.animate(withDuration: 0.05, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: self.viewTranslation.x, y: 0)
                })
                
            }
            
        //Handles functionality after pan (user finger HAS LEFT screen)
        case .ended:
            
            print("END")
        
            //Bounced VC back to original position if not dragged past halfway point
            if viewTranslation.x < (screenWidth * 0.5) {
 
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: 0)
                })
                
            } else if viewTranslation.x < 0 {
                print("NO")
                
            } else {
                
                //Bounced VC back to original position if not dragged past halfway point for unexpected event
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: 0)
                })
                
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
    
    //Changes status bar text to black to contrast against white background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
}
