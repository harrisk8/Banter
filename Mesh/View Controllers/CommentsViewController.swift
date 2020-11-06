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

protocol refreshNearbyTable {
    func refreshtable()
}

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
    
    var commentsArray: [[String: AnyObject]]?
    
    var didFastSwipe = false
    
    var delegate: refreshNearbyTable?
    
    var commentTimestamp: Double?
    
    var segueFromInbox = false
    
    var inboxPostArrayPosition: Int?
    
    var postLoadedFromCoreData: Bool?

    
    override func viewDidLoad() {
        

        overrideUserInterfaceStyle = .light
            
        super.viewDidLoad()
        
        postMessage.text = nearbyPostsFinal.finalNearbyPostsArray[postArrayPosition ?? 0].message

    
        if postLoadedFromCoreData == true {
            print("OLD POST")
            updateOldPostData()
            
        } else {
            print("NEWPOST")
            commentsArray = nearbyPostsFinal.finalNearbyPostsArray[self.postArrayPosition ?? 0].comments

            DispatchQueue.main.async {
                self.commentsTableView.reloadData()
            }
        }
    
        

        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.register(UINib(nibName: "NearbyTableCell", bundle: nil), forCellReuseIdentifier: "NearbyTableCell")
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
    
    func updateOldPostData() {
        
        let databaseRef = database.collection("posts").document(nearbyPostsFinal.finalNearbyPostsArray[postArrayPosition ?? 0].documentID ?? "")
        
        databaseRef.getDocument { (document, error) in
            
        if let document = document, document.exists {
            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
            print("Document data: \(dataDescription)")
            print("FETCHEDDOC")
            print(document.data() as Any)
            
            let postData = document.data()
            
            if let postAuthor = postData?["author"] as? String,
                let postMessage = postData?["message"] as? String,
                let postScore = postData?["score"] as? Int32?,
                let postTimestamp = postData?["timestamp"] as? Double,
                let postComments = postData?["comments"] as? [[String: AnyObject]]?,
                let postID = document.documentID as String?
            {
                let updatedPostCell = NearbyCellData(
                    author: postAuthor,
                    message: postMessage,
                    score: postScore,
                    timestamp: postTimestamp,
                    comments: postComments,
                    documentID: postID,
                    loadedFromCoreData: true
                )
                
                nearbyPostsFinal.finalNearbyPostsArray.remove(at: self.postArrayPosition ?? 0)
                nearbyPostsFinal.finalNearbyPostsArray.append(updatedPostCell)
                
                nearbyPostsFinal.finalNearbyPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
                    // you can have additional code here
                    return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
                    
                }
                
                self.commentsArray = nearbyPostsFinal.finalNearbyPostsArray[self.postArrayPosition ?? 0].comments

                DispatchQueue.main.async {
                    self.commentsTableView.reloadData()
                }
                
            }
            
        } else {
            print("Document does not exist")
        }

        }
        
    }
    
    

    
    //Changes status bar text to black to contrast against white background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.darkContent
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "commentsToReport", sender: self)
    }
    
    
    //Detects if user taps talbe during editing process
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tap")
        print(indexPath.row)
        
        
        if commentsTextView.isFirstResponder == true {
            commentsTextView.resignFirstResponder()
            slideCommentEditorDown()
            
        }
  
    
        commentsTableView.deselectRow(at: indexPath, animated: false)
        print("deselect")

    }
    
  
    

    
    @IBAction func postCommentPressed(_ sender: Any) {
        
        //Slides comment editor up for message compsition if button pressed while editor is down
        if commentsTextView.isFirstResponder == false {
            commentsTextView.becomeFirstResponder()

        } else if commentsTextView.text != "" && commentsTextView.isFirstResponder == true {
            
            commentTimestamp = Date().timeIntervalSince1970
            
            commentData = ["author" : UserInfo.userAppearanceName as AnyObject, "message" : commentsTextView.text as AnyObject, "commentTimestamp" : commentTimestamp as AnyObject]
            
            writeCommentToDatabase()
            
            nearbyPostsFinal.finalNearbyPostsArray[postArrayPosition ?? 0].comments?.append(commentData!)
            commentsArray?.append(commentData!)
            
            DispatchQueue.main.async {
                self.commentsTableView.reloadData()
            }
            
            commentsTextView.resignFirstResponder()
            slideCommentEditorDown()

            
        }
        
        
        
        delegate?.refreshtable()

        
    }
    
    
    func writeCommentToDatabase() {
        
        let docID: String = nearbyPostsFinal.finalNearbyPostsArray[postArrayPosition ?? 0].documentID ?? ""
        print(docID)
        
        let databaseRef = database.collection("posts").document(docID)


        databaseRef.updateData([

            "comments": FieldValue.arrayUnion([commentData!]),
            "lastCommentTimestamp": commentTimestamp ?? 0.0
            

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
        
        if segueFromInbox == false {
            
            return (nearbyPostsFinal.finalNearbyPostsArray[postArrayPosition ?? 0].comments?.count ?? 0)
            
        } else if segueFromInbox == true {
            
            print(InboxArray.inboxArrayNew[inboxPostArrayPosition ?? 0].comments?.count ?? 0)
            return (InboxArray.inboxArrayNew[inboxPostArrayPosition ?? 0].comments?.count ?? 0)
                        
        }
            
            
           return 10
        
    }
    
    //Populates table cells with data from array
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(indexPath.row)
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyTableCell", for: indexPath) as! NearbyTableCell
        
        
        if indexPath.row == (nearbyPostsFinal.finalNearbyPostsArray[postArrayPosition ?? 0].comments?.count ?? 0) {
            print("GO")
            
            cell.authorLabel?.text = "testcell"
            cell.messageLabel?.text = "testcell"
            cell.timestampLabel?.text = "testcell"
            
            return cell
        }
        
        
        cell.authorLabel?.text = commentsArray?[indexPath.row]["author"] as? String
        
        
        cell.messageLabel?.text = commentsArray?[indexPath.row]["message"] as? String
        cell.timestampLabel?.text = "5"
        
        return cell
        
    }
    
    //Slides comment text view editor up as keyboard slides up
    func slideCommentEditorUp() {
        
        self.commentsEditorView.translatesAutoresizingMaskIntoConstraints = true

        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, animations: {
                self.commentsEditorView.frame.origin.y -= CGFloat(self.keyboardHeight ?? 0)
            })
        }
        
    }
    
    //Slides comment text view down after post or dismissal swipe
    func slideCommentEditorDown() {
        
        pointsScrolled = 0
        UIView.animate(withDuration: 0.2) {
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
        pointsScrolled = 0
    }

    //Handles scroll detection
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                
        if self.lastContentOffset < commentsTableView.contentOffset.y {
            
            //User Scrolled Down
            
        } else if self.lastContentOffset > commentsTableView.contentOffset.y  {
            //User Scrolled Up
            
            pointsScrolled += 1
            print(pointsScrolled
            )
            
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
                
        self.view.translatesAutoresizingMaskIntoConstraints = true
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

            //Prevents VC from sliding to the left and allows screen to follow finger
            if viewTranslation.x > 0 && velocity.x <= 1750 {
                
                DispatchQueue.main.async {
                                        
                    UIView.animate(withDuration: 0.025, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.view.frame.origin.x = CGFloat(self.viewTranslation.x)
                    })

                }
            }
            
        //Handles functionality after pan (user finger HAS LEFT screen)
        case .ended:
        
            if velocity.x > 1750 {
                
                DispatchQueue.main.async {

                    UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.view.frame.origin.x = CGFloat(self.screenWidth)
                    }, completion: { [weak self] _ in
                        self?.commentsTextView.resignFirstResponder()
                        self?.dismiss(animated: false, completion: nil)
                    })
                }
            }
            
            if velocity.x <= 1750 {
                                
                DispatchQueue.main.async {

                    UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.view.frame.origin.x = CGFloat(0)
                    })
                }
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
