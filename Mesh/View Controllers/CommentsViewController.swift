//
//  CommentsViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 9/13/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var commentEditorView: UIView!
    
    @IBOutlet weak var postMessage: UILabel!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var postArrayPosition: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        
        postMessage.text = NearbyArray.nearbyArray[postArrayPosition ?? 0].message

    }
    
    func slideCommentEditorUp() {
        
        UIView.animate(withDuration: 0.3) {
            self.commentEditorView.frame.origin.y -= CGFloat(UserInfo.keyboardHeight ?? 0)
        }
    
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("GO")
        slideCommentEditorUp()
    }
    
    
    @IBAction func userSwipesBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
