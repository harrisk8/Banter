//
//  NearbyTableCell.swift
//  Mesh
//
//  Created by Harris Kapoor on 9/30/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class NearbyTableCell: UITableViewCell {
    
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var postScoreLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    var likedPost = false
    var dislikedPost = false
    var likedFromDislike = true
    var dislikedFromLike = false
    var randomInt = 0
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        
        
        if dislikedPost == true {
            print("DISLIKE -> LIKE")
            randomInt += 2
            likeButton.setImage(UIImage(named: "Like Button Selected"), for: .normal)
            dislikeButton.setImage(UIImage(named: "Dislike Button Regular"), for: .normal)
            dislikedPost = false
            likedPost = true

        }
        
        if likedPost == false {
            print("LIKE")
            randomInt += 1
            likeButton.setImage(UIImage(named: "Like Button Selected"), for: .normal)
            postScoreLabel?.text = String(randomInt)
            likedPost = true
        } else if likedPost == true {
            print("Removing Like")
            randomInt -= 1
            likeButton.setImage(UIImage(named: "Like Button Regular"), for: .normal)
            postScoreLabel?.text = String(randomInt)
            likedPost = false
        }
    }
    
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        
        if likedPost == true {
            randomInt -= 2
            dislikeButton.setImage(UIImage(named: "Dislike Button Selected"), for: .normal)
            likeButton.setImage(UIImage(named: "Like Button Regular"), for: .normal)
            likedPost = false
            dislikedPost = true
            
        }
        
        
        if dislikedPost == false {
            print("DISLIKE")
            randomInt -= 1
            dislikeButton.setImage(UIImage(named: "Dislike Button Selected"), for: .normal)
            postScoreLabel?.text = String(randomInt)
            dislikedPost = true
        } else if dislikedPost == true {
            print("Removing Dislike")
            randomInt += 1
            dislikeButton.setImage(UIImage(named: "Dislike Button Regular"), for: .normal)
            postScoreLabel?.text = String(randomInt)
            dislikedPost = false
            }
    }
    
}
