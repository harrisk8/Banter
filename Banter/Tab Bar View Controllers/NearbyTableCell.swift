//
//  NearbyTableCell.swift
//  Mesh
//
//  Created by Harris Kapoor on 9/30/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//


protocol cellVotingDelegate: AnyObject {
    
    func userPressedVoteButton(_ cell: NearbyTableCell, _ caseType: voteType)
}


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
    
    weak var delegate: cellVotingDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    @IBAction func likeButtonPressed(_ sender: Any) {
        
        
        if dislikedPost == true && likedPost == false {
            
//            print("Removing Dislike Via Like Button")
            randomInt += 1
            dislikeButton.setImage(UIImage(named: "Dislike Button Regular"), for: .normal)
            dislikedPost = false
            delegate?.userPressedVoteButton(self, .likeFromDislike)
            
        } else if likedPost == false && dislikedPost == false {
            
//            print("LIKE")
            randomInt += 1
            likeButton.setImage(UIImage(named: "Like Button Selected"), for: .normal)
            likedPost = true
            delegate?.userPressedVoteButton(self, .like)
            
        } else if likedPost == true {
            
//            print("Removing Like")
            randomInt -= 1
            likeButton.setImage(UIImage(named: "Like Button Regular"), for: .normal)
            likedPost = false
            delegate?.userPressedVoteButton(self, .removeLike)

        }
        
    }
    
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        
        if likedPost == true && dislikedPost == false {
            
//            print("Removing Like Via Dislike Button")
            randomInt -= 1
            likeButton.setImage(UIImage(named: "Like Button Regular"), for: .normal)
            likedPost = false
            dislikedFromLike = true
            delegate?.userPressedVoteButton(self, .dislikeFromLike)

        } else if dislikedPost == false && likedPost == false {
            
//            print("DISLIKE")
            randomInt -= 1
            dislikeButton.setImage(UIImage(named: "Dislike Button Selected"), for: .normal)
            dislikedPost = true
            delegate?.userPressedVoteButton(self, .dislike)

        } else if dislikedPost == true {
            
//            print("Removing Dislike")
            randomInt += 1
            dislikeButton.setImage(UIImage(named: "Dislike Button Regular"), for: .normal)
            dislikedPost = false
            delegate?.userPressedVoteButton(self, .removeDislike)

        }
        
    }
    
}
