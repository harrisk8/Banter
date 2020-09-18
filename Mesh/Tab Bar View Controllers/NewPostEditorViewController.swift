//
//  NewPostEditorViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/24/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase

class NewPostEditorViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var postMessageButton: UIButton!
    
    @IBOutlet weak var postingAsLabel: UILabel!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    
    @IBOutlet weak var messageEditor: UITextView!
    
    let database = Firestore.firestore()
    
    var timestamp: Double = 0

    var testArray: [[String: Any]] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageEditor.delegate = self
        
        messageEditor.becomeFirstResponder()

        
        organizePostingAsLabel()
        
        testArray.append(["author" : "Chang", "message" : "what's good jimbo"])
        testArray.append(["author" : "Jaci", "message" : "stuff, G"])

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
            "timestamp": timestamp,
            "comments": testArray
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
    
    
    //Dismisses VC when user swiped down
    @IBAction func swipeDownDetected(_ sender: Any) {
        print("user swiped down")
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        messageEditor.text = ""
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
        
        let attributedPartTwo = NSMutableAttributedString(string: UserInfo.userAppearanceName, attributes: partTwoAttributes)

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

}
