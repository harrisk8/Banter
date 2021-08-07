//
//  NewPostEditorViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/24/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import FirebaseFirestore


class NewPostEditorViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, updatePostingAsName {
    
    
    func updatePostingAsLabel() {
        print("NEWNAMEUDPATE")
        organizePostingAsLabel()
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var changePostingAsButton: UIButton!
    @IBOutlet weak var changePostingToButton: UIButton!
    
    @IBOutlet weak var postMessageButton: UIButton!
    
    @IBOutlet weak var postingAsLabel: UILabel!
    @IBOutlet weak var postingToLabel: UILabel!
    
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var messageEditor: UITextView!
    
    let database = Firestore.firestore()
    
    var timestampOfPostCreated: Double = 0

    var testArray: [[String: Any]] = []
    
    var newDocumentID: String?
    var newScore: Int32?
    
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let randomInt: Int32 = Int32(Int.random(in: 1...100))
    
    var timestampForFetchingNearbyPostsBeforeUsersPost: Double?
    var timestampForFetchingSchoolPostsBeforeUsersPost: Double?
    
    var postToSchool = false
    var postToNearby = true
    
    //Configures state to avoid creating two new posts if user presses post button in rapid succession.
    var processingNewPost = false

        
    override func viewDidLoad() {
        
        overrideUserInterfaceStyle = .light
        
        super.viewDidLoad()
        
        messageEditor.delegate = self
        
        messageEditor.layer.cornerRadius = 17.5
        
        messageEditor.becomeFirstResponder()
        
        organizePostingAsLabel()
        
        testArray.append(["author" : "Jack", "message" : "Hi everyone! (This is a test comment)"])
        testArray.append(["author" : "Bob", "message" : "What's up? This is a test comment)"])
        testArray.append(["author" : "William", "message" : "Hello. This is a test comment)"])

        
        
        
        if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 0 {
            timestampForFetchingNearbyPostsBeforeUsersPost = 0.0
        } else {
            timestampForFetchingNearbyPostsBeforeUsersPost = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp
        }
        
        if MySchoolPosts.MySchoolPostsArray.count == 0 {
            timestampForFetchingSchoolPostsBeforeUsersPost = 0.0
        } else {
            timestampForFetchingSchoolPostsBeforeUsersPost = MySchoolPosts.MySchoolPostsArray[0].timestamp
        }
        
        //Configures logic for whether the user last posted to school or nearby
        if (UserDefaults.standard.bool(forKey: "postToSchool")) == true {
            
            print("User last set to posttoschool")
            
            postToSchool = true
            postToNearby = false
            
            organizePostingToLabel(changeLabelToNearby: false, changeLabelToSchool: true)
            
        } else {
            
            print("User last set to posttonearby")
            
            postToSchool = false
            postToNearby = true
            
            organizePostingToLabel(changeLabelToNearby: true, changeLabelToSchool: false)
        }
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        print("New Post View Appeared")
    }
    
    
    //Post button functionality - validates message, assigns timestamp, writes, and dismisses VC.
    @IBAction func postMessagePressed(_ sender: Any) {
        
        if validateMessage() && processingNewPost == false {
            
            if postToSchool == true && postToNearby == false {
                //Post to school
                
                processingNewPost = true
                timestampOfPostCreated = Date().timeIntervalSince1970
                fetchSchoolPostsBeforeUsersPost()
                
            } else if postToSchool == false && postToNearby == true {
                //Post to nearby
                
                processingNewPost = true
                timestampOfPostCreated = Date().timeIntervalSince1970
                fetchNearbyPostsBeforeUsersPost()
                
            }
            
        }
    }
    
    
    //Handles writing new post to database
    func writeNewPostToNearbyCollection() {
                        
        var ref: DocumentReference? = nil

        ref = database.collection("posts").addDocument(data: [
                        
            "author": UserInfo.userAppearanceName as Any,
            "userDocID": UserInfo.userCollectionDocID ?? "",
            "comments": testArray,
            "locationCity": UserInfo.userCity ?? "",
            "locationState": UserInfo.userState ?? "",
            "userSchool": "",
            "message": messageEditor.text ?? "",
            "score": 0,
            "timestamp": timestampOfPostCreated,
            "lastCommentTimestamp": 0.0
        
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("Document successfully written")
                print(ref?.documentID ?? "")
                
                self.newDocumentID = ref?.documentID
                
                //Add user generated post to nearbyFinal array and then to Core Data
                self.appendNewNearbyPostToNearbyArray()

            }
        }
        
        
    }
    
    //Handles writing new post to database
    func writeNewPostToSchoolCollection() {
                        
        var ref: DocumentReference? = nil

        ref = database.collection("posts").addDocument(data: [
                        
            "author": UserInfo.userAppearanceName as Any,
            "userDocID": UserInfo.userCollectionDocID ?? "",
            "comments": testArray,
            "locationCity": UserInfo.userCity ?? "",
            "locationState": UserInfo.userState ?? "",
            "userSchool": UserInfo.userSchool ?? "",
            "message": messageEditor.text ?? "",
            "score": 0,
            "timestamp": timestampOfPostCreated,
            "lastCommentTimestamp": 0.0
        
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("Document successfully written")
                print(ref?.documentID ?? "")
                
                self.newDocumentID = ref?.documentID
                
                //Add user generated post to nearbyFinal array and then to Core Data
                self.appendNewSchoolPostToSchoolArray()

            }
        }
        
        
    }
    
    
    func fetchNearbyPostsBeforeUsersPost() {
        
        if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 0 {
            timestampForFetchingNearbyPostsBeforeUsersPost = 0.0
        } else {
            timestampForFetchingNearbyPostsBeforeUsersPost = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp ?? 0.0
        }
        
        database.collection("posts")
            .whereField("timestamp", isGreaterThan: timestampForFetchingNearbyPostsBeforeUsersPost)
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
                           let postID = document.documentID as String?,
                            let postUserDocID = postData["userDocID"] as? String
                            
                       {
                           let newPost = NearbyCellData(
                               author: postAuthor,
                               message: postMessage,
                               score: postScore ?? 0,
                               timestamp: postTimestamp,
                               comments: postComments ?? nil,
                               documentID: postID,
                               userDocID: postUserDocID
                            )
                        
                        print(" - - - -New post before users post - - - - ")
                        print(newPost)
                           
                        newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.append(newPost)
                           
                       }
                       
                   }
                
                self.writeNewPostToNearbyCollection()
                
               }
                   
           }
        
    }
    
    func fetchSchoolPostsBeforeUsersPost() {
        
        if MySchoolPosts.MySchoolPostsArray.count == 0 {
            timestampForFetchingSchoolPostsBeforeUsersPost = 0.0
        } else {
            timestampForFetchingSchoolPostsBeforeUsersPost = MySchoolPosts.MySchoolPostsArray[0].timestamp ?? 0.0
        }
        
        database.collection("posts")
            .whereField("timestamp", isGreaterThan: timestampForFetchingSchoolPostsBeforeUsersPost)
                .whereField("userSchool", isEqualTo: UserInfo.userSchool ?? "")
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
                        let postID = document.documentID as String?,
                        let postUserDocID = postData["userDocID"] as? String,
                        let postSchoolName = postData["schoolName"] as? String
                    {
                        
                        let newPost = MySchoolCellData(
                            author: postAuthor,
                            message: postMessage,
                            score: postScore,
                            timestamp: postTimestamp,
                            comments: postComments ?? nil,
                            documentID: postID,
                            userDocID: postUserDocID,
                            schoolName: postSchoolName,
                            likedPost: false,
                            dislikedPost: false
                        )
                        
                        print(" - - - -New post before users post - - - - ")
                        print(newPost)
                           
                        MySchoolPosts.MySchoolPostsArray.append(newPost)
                           
                       }
                       
                   }
                
                self.writeNewPostToSchoolCollection()
                
               }
                   
           }
        
    }
    
    
    
    //Locally appends nearby array with new post created by the user.
    func appendNewNearbyPostToNearbyArray() {

        let newPostData = NearbyCellData(
            author: UserInfo.userAppearanceName,
            message: messageEditor.text,
            score: 0,
            timestamp: timestampOfPostCreated,
            comments: [] as [[String : AnyObject]],
            documentID: newDocumentID,
            userDocID: UserInfo.userCollectionDocID,
            likedPost: false,
            dislikedPost: false
        )
        
        newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.insert(newPostData, at: 0)
        
        organizeNearbyArray()
        
    }
    
    func appendNewSchoolPostToSchoolArray() {

        let newPostData = MySchoolCellData(
            author: UserInfo.userAppearanceName,
            message: messageEditor.text,
            score: 0,
            timestamp: timestampOfPostCreated,
            comments: [] as [[String : AnyObject]],
            documentID: newDocumentID,
            userDocID: UserInfo.userCollectionDocID,
            schoolName: UserInfo.userSchool,
            likedPost: false,
            dislikedPost: false
        )
        
        MySchoolPosts.MySchoolPostsArray.insert(newPostData, at: 0)
        
        organizeSchoolArray()
        
    }
    
    func organizeNearbyArray() {
        
        
        processingNewPost = false
        
        //Sort by timestamp
        newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.sort{ (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
            return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func organizeSchoolArray() {
        
        
        processingNewPost = false
        
        //Sort by timestamp
        MySchoolPosts.MySchoolPostsArray.sort{ (lhs: MySchoolCellData, rhs: MySchoolCellData) -> Bool in
            return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //Checks to make sure text field is not empty.
    func validateMessage() -> Bool {
        if messageEditor.text != "" {
            return true
        }
        return false
    }
    
    
    
    
    //Dismiss VC
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //Dismisses VC when user swiped down
    @IBAction func swipeDownDetected(_ sender: Any) {
        print("user swiped down")
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        messageEditor.text = ""
        characterCountLabel.text = "0/240"
    }
    
    
    //Formates the "Posting as: 'appearance name'" label
    func organizePostingAsLabel() {

        let partOneAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 35/255, green: 8/255, blue: 58/255, alpha: 1),
            .font: UIFont(name: "Roboto-Regular", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        ]
        
        let partTwoAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 35/255, green: 8/255, blue: 58/255, alpha: 1),
            .font: UIFont(name: "Roboto-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        ]
        
        let attributedPartOne = NSMutableAttributedString(string: "Posting as: ", attributes: partOneAttributes)
        
        let attributedPartTwo = NSMutableAttributedString(string: UserDefaults.standard.string(forKey: "lastUserAppearanceName") ?? "", attributes: partTwoAttributes)

        attributedPartOne.append(attributedPartTwo)
        
        postingAsLabel.adjustsFontSizeToFitWidth = true
        postingAsLabel.attributedText = attributedPartOne
                
    }
    
    func organizePostingToLabel(changeLabelToNearby: Bool, changeLabelToSchool: Bool) {

        let partOneAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 35/255, green: 8/255, blue: 58/255, alpha: 1),
            .font: UIFont(name: "Roboto-Regular", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        ]
        
        let partTwoAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 35/255, green: 8/255, blue: 58/255, alpha: 1),
            .font: UIFont(name: "Roboto-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        ]
        
        let attributedPartOne = NSMutableAttributedString(string: "Posting to: ", attributes: partOneAttributes)
        
        let attributedMySchool = NSMutableAttributedString(string: "My School", attributes: partTwoAttributes)
        
        let attributedNearby = NSMutableAttributedString(string: "Nearby", attributes: partTwoAttributes)
        
        if changeLabelToNearby == true && changeLabelToSchool == false {
            //Change label to nearby
            
            attributedPartOne.append(attributedNearby)

        } else if changeLabelToNearby == false && changeLabelToSchool == true {
            //Change label to school
            
            attributedPartOne.append(attributedMySchool)
            
        }
        
        postingToLabel.adjustsFontSizeToFitWidth = true
        postingToLabel.attributedText = attributedPartOne
                
    }
    
    //Updates character count label in real-time
    func textViewDidChange(_ textView: UITextView) {
        let characterCount: String
        characterCount = String(messageEditor.text.count)
        characterCountLabel.text = characterCount + "/240"
    }

    
    //Functionally disables the return button and limits message length to 240 char
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
        if text == "\n" {
            return false
            
        }
        return messageEditor.text.count + (text.count - range.length) <= 240
    }
    
    //Changes status bar text to black to contrast against white background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    @IBAction func changePostingAsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "newPostToChange", sender: self)
    }
    
    
    @IBAction func changePostingToButtonPressed(_ sender: Any) {
        
        if postToSchool == true && postToNearby == false {
            //Switching from post to school --> post to nearby
            
            organizePostingToLabel(changeLabelToNearby: true, changeLabelToSchool: false)
            
            postToSchool = false
            postToNearby = true
            
            UserDefaults.standard.setValue(false, forKey: "postToSchool")
            
        } else if postToSchool == false && postToNearby == true {
            //Switching from post to nearby --> post to school
            
            organizePostingToLabel(changeLabelToNearby: false, changeLabelToSchool: true)
            
            postToSchool = true
            postToNearby = false
            
            UserDefaults.standard.setValue(true, forKey: "postToSchool")

            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let appearingAsVC = segue.destination as? AppearAsViewController {
            
          
            AppearAsViewController.updateDelegate = self
            
        }
    }
    
    
}
