//
//  NewPostEditorViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/24/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase

class NewPostEditorViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var postMessageButton: UIButton!
    
    
    @IBOutlet weak var messageEditor: UITextView!
    
    let database = Firestore.firestore()
    
    var timestamp: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageEditor.becomeFirstResponder()

        cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true

    }
    
    
    //Post button functionality - validates message, assigns timestamp, writes, and dismisses VC.
    @IBAction func postMessagePressed(_ sender: Any) {
        print("write")
        if validateMessage() {
            timestamp = Date().timeIntervalSince1970
            writePostToDatabase()
            appendNewPostToArray()
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    //Handles writing new post to database
    func writePostToDatabase() {
        
        database.collection("posts").addDocument(data: [
            "author": UserInfo.userAppearanceName,
            "authorID": UserInfo.userID ?? "",
            "message": messageEditor.text ?? "",
            "timestamp": timestamp
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("Document successfully written")
            }
        }
        
    }
    
    //Locally appends nearby array with new post.
    func appendNewPostToArray() {
        
        let newPostCell = NearbyCellData(author: UserInfo.userAppearanceName, message: messageEditor.text ?? "", timestamp: timestamp)
        
        NearbyArray.nearbyArray.insert(newPostCell, at: 0)
        
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
    
    
    
    
    //Functionally disables 'return' button on keyboard.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
        if text == "\n" {
            return false
        }
        return messageEditor.text.count + (text.count - range.length) <= 240
    }


}
