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
import CoreData

class VotingModel {
    
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var oldPostsFetchedFromCoreData: [VoteEntity]?
    
    let database = Firestore.firestore()
    
    
    func sendVoteToDatabase2(votePathway: votePathway, postPositionInRespectiveArray: Int, voteType: voteType) {
        
        switch votePathway {
        
        case .voteFromMySchool:
            print("test")
            
            let databaseRefSchool = database.collection("posts").document(MySchoolPosts.MySchoolPostsArray[postPositionInRespectiveArray].documentID ?? "")
            
            executeTransaction(databaseRef: databaseRefSchool, voteType: voteType)
            
        case .voteFromNearby:
            print("test")
            
            let databaseRefNearby = database.collection("posts").document(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postPositionInRespectiveArray].documentID ?? "")
            
            executeTransaction(databaseRef: databaseRefNearby, voteType: voteType)


            
        case .voteFromTrending:
            print("test")
            
            let databaseRefTrending = database.collection("posts").document(formattedTrendingPosts.formattedTrendingPostsArray[postPositionInRespectiveArray].documentID ?? "")
            
            executeTransaction(databaseRef: databaseRefTrending, voteType: voteType)
        
        }
        
    }
    
    
    func executeTransaction(databaseRef: DocumentReference, voteType: voteType) {
        
        
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
            
            // Note: this could be done without a transaction
            //       by updating the population using FieldValue.increment()
            
            let votingTransaction: voteType = voteType
            
            switch votingTransaction {
            
            case .like:
                print("Like")
                transaction.updateData(["score": oldScore + 1], forDocument: databaseRef)
            case .dislike:
                print("Dislike")
                transaction.updateData(["score": oldScore - 1], forDocument: databaseRef)
            case .removeLike:
                print("Remove Like")
                transaction.updateData(["score": oldScore - 1], forDocument: databaseRef)
            case .removeDislike:
                print("Remove Dislike")
                transaction.updateData(["score": oldScore + 1], forDocument: databaseRef)
            case .dislikeFromLike:
                print("Dislike from Like")
                transaction.updateData(["score": oldScore - 1], forDocument: databaseRef)
            case .likeFromDislike:
                print("Like from Dislike")
                transaction.updateData(["score": oldScore + 1], forDocument: databaseRef)
            }
            
            return nil
            
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
        
    }
    
    
    //True if nearby, false if trending
    func sendVoteToDatabase(postPositionInArray: Int, voteType: voteType, nearbyOrTrending: Bool) {
        
        print(" - - - VOTING MODEL FUNCTION - - - - ")
        print("This post is \(postPositionInArray) in array" )
        print(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postPositionInArray].message as Any)
        
        var databaseRef = database.collection("posts").document()
        
        if nearbyOrTrending == true {
            databaseRef = database.collection("posts").document(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postPositionInArray].documentID ?? "")
        } else {
            databaseRef = database.collection("posts").document(formattedTrendingPosts.formattedTrendingPostsArray[postPositionInArray].documentID ?? "")
        }
    
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
            
            // Note: this could be done without a transaction
            //       by updating the population using FieldValue.increment()
            
            let votingTransaction: voteType = voteType
            
            switch votingTransaction {
            
            case .like:
                print("Like")
                transaction.updateData(["score": oldScore + 1], forDocument: databaseRef)
            case .dislike:
                print("Dislike")
                transaction.updateData(["score": oldScore - 1], forDocument: databaseRef)
            case .removeLike:
                print("Remove Like")
                transaction.updateData(["score": oldScore - 1], forDocument: databaseRef)
            case .removeDislike:
                print("Remove Dislike")
                transaction.updateData(["score": oldScore + 1], forDocument: databaseRef)
            case .dislikeFromLike:
                print("Dislike from Like")
                transaction.updateData(["score": oldScore - 1], forDocument: databaseRef)
            case .likeFromDislike:
                print("Like from Dislike")
                transaction.updateData(["score": oldScore + 1], forDocument: databaseRef)
            }
            
            return nil
            
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
        
    }
    
    
    
    func saveVoteToCoreData(postPositionInArray: Int, voteType: voteType, nearbyOrTrending: Bool) {
        
        let voteData = VoteEntity(context: dataContext)
        
        var postDocumentID = ""
        
        if nearbyOrTrending == true {
            
            postDocumentID = newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[postPositionInArray].documentID ?? ""
        } else {
            
            postDocumentID = formattedTrendingPosts.formattedTrendingPostsArray[postPositionInArray].documentID ?? ""
        }
        
        
        var userLikedPost = false
        var userDislikedPost = false
                
        let votingTransaction: voteType = voteType
        
        switch votingTransaction {
        
        case .like:
            print("Like")
            userLikedPost = true
            userDislikedPost = false
            voteData.documentID = postDocumentID
            voteData.userLikedPost = userLikedPost
            voteData.userDislikedPost = userDislikedPost
            do {
                try dataContext.save()
            }
            catch {
            }
        case .dislike:
            print("Dislike")
            userLikedPost = false
            userDislikedPost = true
            voteData.documentID = postDocumentID
            voteData.userLikedPost = userLikedPost
            voteData.userDislikedPost = userDislikedPost
            do {
                try dataContext.save()
            }
            catch {
            }
        case .removeLike:
            print("Remove Like")
            userLikedPost = false
            userDislikedPost = false
            removeVoteFromCoreData(documentID: postDocumentID)
        case .removeDislike:
            print("Remove Dislike")
            userLikedPost = false
            userDislikedPost = false
            removeVoteFromCoreData(documentID: postDocumentID)
        case .dislikeFromLike:
            print("Dislike from Like")
            userLikedPost = false
            userDislikedPost = false
            removeVoteFromCoreData(documentID: postDocumentID)
        case .likeFromDislike:
            print("Like from Dislike")
            userLikedPost = false
            userDislikedPost = false
            removeVoteFromCoreData(documentID: postDocumentID)
        }
        
        
    }
    
    func removeVoteFromCoreData(documentID: String) {
        
        print("Delete voteData with \(documentID)")
        

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "VoteEntity")
        fetchRequest.predicate = NSPredicate(format: "documentID = %@", documentID)
        
//        do {
//            let result = try dataContext.fetch(fetchRequest)
//            print(result.count)
//            print(result)
//            for object in result {
//                print(object)
//                try dataContext.save()
//                dataContext.delete(object as! NSManagedObject)
//            }
//            try dataContext.save()
//
//        } catch {
//
//        }
        
        
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
                do {
                    try dataContext.execute(deleteRequest)
        
                } catch let error as NSError {
                    print(error)
                }
        
                do {
                    try dataContext.save()
                } catch let error as NSError {
                    print(error)
                }
        
        
        
    }
    
    
    func pullLastSessionVotesFromCoreData() {
        
        
        
    }
}
