//
//  NearbyTableViewCell.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/22/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class NearbyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var messageLabel: UILabel?
    @IBOutlet weak var postScore: UILabel?
    @IBOutlet weak var timestampLabel: UILabel?
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    var likedPost = false
    var dislikedPost = false
    
    var randomInt = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        randomInt = Int.random(in: 1...100)
        postScore?.text = String(randomInt)
    }
    
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        
        if dislikedPost == true {
            print("DISLIKE -> LIKE")
            randomInt += 2
            likeButton.setImage(UIImage(named: "Like Button Selected"), for: .normal)
            dislikeButton.setImage(UIImage(named: "Dislike Button Regular"), for: .normal)
            dislikedPost = false

        }
        
        if likedPost == false {
            print("LIKE")
            randomInt += 1
            likeButton.setImage(UIImage(named: "Like Button Selected"), for: .normal)
            postScore?.text = String(randomInt)
            likedPost = true
        } else {
            print("Removing Like")
            randomInt -= 1
            likeButton.setImage(UIImage(named: "Like Button Regular"), for: .normal)
            postScore?.text = String(randomInt)
            likedPost = false
        }
        

    }
    
    
    
    
    
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        
        if likedPost == true {
            randomInt -= 2
            dislikeButton.setImage(UIImage(named: "Dislike Button Selected"), for: .normal)
            likeButton.setImage(UIImage(named: "Like Button Regular"), for: .normal)
            likedPost = false
            
        }
        
        
        if dislikedPost == false {
            print("DISLIKE")
            randomInt -= 1
            dislikeButton.setImage(UIImage(named: "Dislike Button Selected"), for: .normal)
            postScore?.text = String(randomInt)
            dislikedPost = true
        } else {
            print("Removing Dislike")
            randomInt += 1
            dislikeButton.setImage(UIImage(named: "Dislike Button Regular"), for: .normal)
            postScore?.text = String(randomInt)
            dislikedPost = false
            }
        

        
    }
    
    
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
