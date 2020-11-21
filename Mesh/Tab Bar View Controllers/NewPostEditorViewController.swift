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
            writePostToDatabase()
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
            "score": randomInt,
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
                
                if nearbyPostsFinal.finalNearbyPostsArray.count == 1 {
                    self.addNewPostToCoreData()
                    newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray = []
                    self.timestampForFetchingPostsBeforeUsersPost = nearbyPostsFinal.finalNearbyPostsArray[0].timestamp ?? 0.0
                    self.fetchPostsBeforeUsersPost()
                    
                } else if nearbyPostsFinal.finalNearbyPostsArray.count > 1 {
                    newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray = []
                    self.timestampForFetchingPostsBeforeUsersPost = nearbyPostsFinal.finalNearbyPostsArray[1].timestamp ?? 0.0
                    self.fetchPostsBeforeUsersPost()
                } else {
                    print("FIRST POST IN SYSTEM")
                    newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray = []
                    self.timestampForFetchingPostsBeforeUsersPost = 0.0
                    self.fetchPostsBeforeUsersPost()
                }
                
                
                
                //IF STATEMENT EXECUTE ONLY IF NEARBY ARRAY IS NOT EMPTY TO AVOID CRASH CUZ OF NIL

                
            }
        }

        
        
    }
    
    
    func fetchPostsBeforeUsersPost() {
        
        database.collection("posts")
            .whereField("timestamp", isGreaterThan: timestampForFetchingPostsBeforeUsersPost ?? 0.0)
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
                               loadedFromCoreData: false,
                               userDocID: postUserDocID
                            )
                           
                           newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.append(newPost)
                           
                       }
                       
                   }
                
               }
                   
                   //Prevents app from crashing if there are no new posts to load
                if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 0 {
                    print("No new posts before the user created theirs")
                    self.organizeNearbyArray()
                    UserDefaults.standard.set(self.timestampOfPostCreated, forKey: "lastTimestampPulledFromServer")

                        
                } else if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count != 0 {
                    
                    UserDefaults.standard.set(self.timestampOfPostCreated, forKey: "lastTimestampPulledFromServer")
                    
                    self.appendPostsFetched()
                    self.organizeNearbyArray()
                   }
        
                   print("Number of new posts: " + String(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count))
                   print("NEW Post")
                   print(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray)

           }
        
        
        
    }
    
    func appendPostsFetched() {
        
        if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 1 {
            
            let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                        
            coreDataPostCell.author = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].author
            coreDataPostCell.comments = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].comments as NSArray?
            coreDataPostCell.documentID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].documentID
            coreDataPostCell.message = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].message
            coreDataPostCell.score = (newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].score as Int32?) ?? 0
            coreDataPostCell.timestamp = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].timestamp ?? 0.0
            coreDataPostCell.userDocID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].userDocID
            
            print("Adding one post from refresh to Core Data")
            
            do {
                try dataContext.save()
            }
            catch {
            }
            
        } else if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count > 1 {
            
            for x in 0...((newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count) - 1) {
                
                let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                            
                coreDataPostCell.author = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].author
                coreDataPostCell.comments = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].comments as NSArray?
                coreDataPostCell.documentID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].documentID
                coreDataPostCell.message = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].message
                coreDataPostCell.score = (newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].score as Int32?) ?? 0
                coreDataPostCell.timestamp = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].timestamp ?? 0.0
                coreDataPostCell.userDocID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].userDocID

                
                print("Adding multiple posts to Core Data")
                
                do {
                    try dataContext.save()
                }
                catch {
                }
                
            }
        } else {
            print("No new posts to add to Core Data")
        }
    }
    
    //Adds the post created by the user to Core Data
    func addNewPostToCoreData() {
        print("Appending the users post to core data")
        
        let coreDataPostCell = NearbyPostsEntity(context: dataContext)
                    
        coreDataPostCell.author = UserInfo.userAppearanceName
        coreDataPostCell.comments = [] as NSObject
        coreDataPostCell.documentID = newDocumentID
        coreDataPostCell.message = messageEditor.text ?? ""
        coreDataPostCell.score = randomInt
        coreDataPostCell.timestamp = timestampOfPostCreated
        coreDataPostCell.userDocID = UserInfo.userCollectionDocID
        
        
        do {
            try dataContext.save()
        }
        catch {
        }
        
    }
    
    //Locally appends nearby array with new post created by the user.
    func appendNewPostToArray() {

        let newPostData = NearbyCellData(
            author: UserInfo.userAppearanceName,
            message: messageEditor.text,
            score: randomInt,
            timestamp: timestampOfPostCreated,
            comments: [] as [[String : AnyObject]],
            documentID: newDocumentID,
            loadedFromCoreData: false,
            userDocID: UserInfo.userCollectionDocID
        )
        
        nearbyPostsFinal.finalNearbyPostsArray.insert(newPostData, at: 0)
        
    }
    
    func organizeNearbyArray() {
        
        nearbyPostsFinal.finalNearbyPostsArray.append(contentsOf: newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray)
        
        //Sort by timestamp
        nearbyPostsFinal.finalNearbyPostsArray.sort { (lhs: NearbyCellData, rhs: NearbyCellData) -> Bool in
            return lhs.timestamp ?? 0 > rhs.timestamp ?? 0
        }
        
        if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count != 0 {
            nearbyPostsFinal.finalNearbyPostsArray.remove(at: 0)
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
