//
//  VotingModel.swift
//  Mesh
//
//  Created by Harris Kapoor on 2/27/21.
//  Copyright © 2021 Avidi Technologies. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class VotingModel {
    
    let database = Firestore.firestore()
    
    func sendVoteToDatabase(postPositionInArray: Int, voteType: voteType) {
        
        print(" - - - VOTING MODEL FUNCTION - - - - ")
        print(postPositionInArray)
        print(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postPositionInArray].message as Any)
        print(voteType)
        

        
        let databaseRef = database.collection("posts").document(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postPositionInArray].documentID ?? "")

        database.runTransaction({ (transaction, errorPointer) -> Any? in
            let postDocument: DocumentSnapshot
            do {
                try postDocument = transaction.getDocument(databaseRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let oldScore = postDocument.data()?["score"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(postDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            print(oldScore)

            // Note: this could be done without a transaction
            //       by updating the population using FieldValue.increment()
            
            let votingTransaction: voteType = voteType
            
            switch votingTransaction {
            
            case .like:
                print("Like")
            case .dislike:
                print("Dislike")
            case .removeLike:
                print("Remove Like")
            case .removeDislike:
                print("Remove Dislike")
            case .dislikeFromLike:
                print("Dislike from Like")
            case .likeFromDislike:
                print("Like from Dislike")
            }
            
            
            transaction.updateData(["score": oldScore + 1], forDocument: databaseRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
        
    }
}
