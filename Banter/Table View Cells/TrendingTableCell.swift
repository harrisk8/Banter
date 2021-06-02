//
//  TrendingTableCell.swift
//  Mesh
//
//  Created by Harris Kapoor on 10/3/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//


protocol trendingCellVotingDelegate: AnyObject {
    
    func userPressedTrendingVoteButton(_ cell: TrendingTableCell, _ caseType: voteType)
}

import UIKit

class TrendingTableCell: UITableViewCell {

    
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
    
    weak var trendingVoteDelegate: trendingCellVotingDelegate?
    
    
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
                trendingVoteDelegate?.userPressedTrendingVoteButton(self, .likeFromDislike)
                
            } else if likedPost == false && dislikedPost == false {
                
    //            print("LIKE")
                randomInt += 1
                likeButton.setImage(UIImage(named: "Like Button Selected"), for: .normal)
                likedPost = true
                trendingVoteDelegate?.userPressedTrendingVoteButton(self, .like)
                
            } else if likedPost == true {
                
    //            print("Removing Like")
                randomInt -= 1
                likeButton.setImage(UIImage(named: "Like Button Regular"), for: .normal)
                likedPost = false
                trendingVoteDelegate?.userPressedTrendingVoteButton(self, .removeLike)

            }
            
        }
        
        
        @IBAction func dislikeButtonPressed(_ sender: Any) {
            
            if likedPost == true && dislikedPost == false {
                
    //            print("Removing Like Via Dislike Button")
                randomInt -= 1
                likeButton.setImage(UIImage(named: "Like Button Regular"), for: .normal)
                likedPost = false
                dislikedFromLike = true
                trendingVoteDelegate?.userPressedTrendingVoteButton(self, .dislikeFromLike)

            } else if dislikedPost == false && likedPost == false {
                
    //            print("DISLIKE")
                randomInt -= 1
                dislikeButton.setImage(UIImage(named: "Dislike Button Selected"), for: .normal)
                dislikedPost = true
                trendingVoteDelegate?.userPressedTrendingVoteButton(self, .dislike)

            } else if dislikedPost == true {
                
    //            print("Removing Dislike")
                randomInt += 1
                dislikeButton.setImage(UIImage(named: "Dislike Button Regular"), for: .normal)
                dislikedPost = false
                trendingVoteDelegate?.userPressedTrendingVoteButton(self, .removeDislike)

            }
            
           
        
    }

}
