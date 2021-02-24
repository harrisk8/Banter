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

class NewPostEditorViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, updatePostingAsName {
    
    
    func updatePostingAsLabel() {
        print("NEWNAMEUDPATE")
        organizePostingAsLabel()
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var postMessageButton: UIButton!
    
    @IBOutlet weak var postingAsLabel: UILabel!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var messageEditor: UITextView!
    
    let database = Firestore.firestore()
    
    var timestampOfPostCreated: Double = 0

    var testArray: [[String: Any]] = []
    
    var newDocumentID: String?
    var newScore: Int32?
    
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let randomInt: Int32 = Int32(Int.random(in: 1...100))
    
    var timestampForFetchingPostsBeforeUsersPost: Double?

        
    override func viewDidLoad() {
        
        overrideUserInterfaceStyle = .light
        
        super.viewDidLoad()
        
        messageEditor.delegate = self
        
        messageEditor.becomeFirstResponder()
        
        organizePostingAsLabel()
        
        testArray.append(["author" : "Jack", "message" : "Hi everyone!"])
        testArray.append(["author" : "Bob", "message" : "What's up?"])
        testArray.append(["author" : "William", "message" : "Hello."])


    }

    override func viewDidAppear(_ animated: Bool) {
        print("viewappeared")
    }
    
    
    //Post button functionality - validates message, assigns timestamp, writes, and dismisses VC.
    @IBAction func postMessagePressed(_ sender: Any) {
        if validateMessage() {
            timestampOfPostCreated = Date().timeIntervalSince1970
            timestampForFetchingPostsBeforeUsersPost = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp
            fetchPostsBeforeUsersPost()
        }
    }
    
    
    //Handles writing new post to database
    func writePostToDatabase() {
                        
        var ref: DocumentReference? = nil

        ref = database.collection("posts").addDocument(data: [
                        
            "author": UserInfo.userAppearanceName as Any,
            "userDocID": UserInfo.userCollectionDocID ?? "",
//            "comments": testArray,
            "locationCity": "Gainesville",
            "locationState": "FL",
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
                self.appendNewPostToArray()

            }
        }
        
        
    }

    
    
    func fetchPostsBeforeUsersPost() {
        
        if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 0 {
            timestampForFetchingPostsBeforeUsersPost = 0.0
        } else {
            timestampForFetchingPostsBeforeUsersPost = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp ?? 0.0
        }
        
        database.collection("posts")
            .whereField("timestamp", isGreaterThan: timestampForFetchingPostsBeforeUsersPost)
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
                        
                        print(" - - - -new post before users post - - - - ")
                        print(newPost)
                           
                        newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.append(newPost)
                        
                        
                           
                       }
                       
                   }
                
                self.writePostToDatabase()
                
               }
                   
           }
        
    }
    
    
    
    //Locally appends nearby array with new post created by the user.
    func appendNewPostToArray() {

        let newPostData = NearbyCellData(
            author: UserInfo.userAppearanceName,
            message: messageEditor.text,
            score: 0,
            timestamp: timestampOfPostCreated,
            comments: [] as [[String : AnyObject]],
            documentID: newDocumentID,
            userDocID: UserInfo.userCollectionDocID
        )
        
        newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.insert(newPostData, at: 0)
        
        organizeNearbyArray()
        
    }
    
    func organizeNearbyArray() {
        
        //Sort by timestamp
        newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.sort{ (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
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
        
        let attributedPartTwo = NSMutableAttributedString(string: UserInfo.userAppearanceName ?? "", attributes: partTwoAttributes)

        attributedPartOne.append(attributedPartTwo)
        
        postingAsLabel.adjustsFontSizeToFitWidth = true
        postingAsLabel.attributedText = attributedPartOne
                
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
    
    @IBAction func changePressed(_ sender: Any) {
        performSegue(withIdentifier: "newPostToChange", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let appearingAsVC = segue.destination as? AppearAsViewController {
            
          
            appearingAsVC.delegate = self
            
        }
    }
    
    
}
