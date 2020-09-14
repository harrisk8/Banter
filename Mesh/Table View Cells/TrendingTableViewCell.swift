//
//  TrendingTableViewCell.swift
//  Mesh
//
//  Created by Harris Kapoor on 9/12/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class TrendingTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var postScore: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    
    var likedPost = false
    var dislikedPost = false
    
    var likedFromDislike = true
    var dislikedFromLike = false
    
    var randomInt = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        randomInt = Int.random(in: 1...100)
        postScore?.text = String(randomInt)

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
            postScore?.text = String(randomInt)
            likedPost = true
        } else if likedPost == true {
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
            dislikedPost = true
            
        }
        
        
        if dislikedPost == false {
            print("DISLIKE")
            randomInt -= 1
            dislikeButton.setImage(UIImage(named: "Dislike Button Selected"), for: .normal)
            postScore?.text = String(randomInt)
            dislikedPost = true
        } else if dislikedPost == true {
            print("Removing Dislike")
            randomInt += 1
            dislikeButton.setImage(UIImage(named: "Dislike Button Regular"), for: .normal)
            postScore?.text = String(randomInt)
            dislikedPost = false
        }
        
        
    }
    
}
