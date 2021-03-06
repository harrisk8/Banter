//
//  StartupSequence.swift
//  Banter
//
//  Created by Harris Kapoor on 5/21/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import CoreData

class StartupSequence {
    
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var votesPulledFromCoreData: [VoteEntity] = []
    
    func pullVotesFromCoreData() {
        
        print(" - - - - - - - trying to get votes from core data - - - - - - -")
        
        do {
            self.votesPulledFromCoreData = try dataContext.fetch(VoteEntity.fetchRequest())
        }
        catch {
            
        }
                
        if votesPulledFromCoreData.count == 1 {
            
            let votePulledFromCoreDataFormatted = voteFromCoreData(
                documentID: votesPulledFromCoreData[0].documentID,
                likedPost: votesPulledFromCoreData[0].userLikedPost,
                dislikedPost: votesPulledFromCoreData[0].userDislikedPost
            )
            
            votesFromCoreData.votesFromCoreDataArray.append(votePulledFromCoreDataFormatted)
            
            print(votesFromCoreData.votesFromCoreDataArray)
            
            
        } else if votesPulledFromCoreData.count > 1 {
            
            for x in 0...(votesPulledFromCoreData.count - 1) {
                
                let votePulledFromCoreDataFormatted = voteFromCoreData(
                    documentID: votesPulledFromCoreData[x].documentID,
                    likedPost: votesPulledFromCoreData[x].userLikedPost,
                    dislikedPost: votesPulledFromCoreData[x].userDislikedPost
                )
                
                votesFromCoreData.votesFromCoreDataArray.append(votePulledFromCoreDataFormatted)

            }
            
            print(" - - - - VOTES FROM CORE DATA - - - - ")

            for x in 0...(votesFromCoreData.votesFromCoreDataArray.count - 1) {
                print(votesFromCoreData.votesFromCoreDataArray[x])
            }
            
            
        } else {
            
            print("No votes were stored in CoreData")
            
        }
        
    }
    
    
    func crosscheckCoreDataVotesToNewlyFetchedPosts() {
        
        if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 1  && votesFromCoreData.votesFromCoreDataArray.count > 1 {
            
            for x in 0...(votesFromCoreData.votesFromCoreDataArray.count - 1) {
                
                if votesFromCoreData.votesFromCoreDataArray[x].documentID == newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].documentID {
                    
                    newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].likedPost = votesFromCoreData.votesFromCoreDataArray[x].likedPost
                    newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].dislikedPost = votesFromCoreData.votesFromCoreDataArray[x].dislikedPost
                    
                }
                
            }
            
        } else if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count > 1  && votesFromCoreData.votesFromCoreDataArray.count > 1 {
            
            for x in 0...(votesFromCoreData.votesFromCoreDataArray.count - 1) {
                
                for y in 0...(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count - 1) {
                    
                    if votesFromCoreData.votesFromCoreDataArray[x].documentID == newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[y].documentID {
                        
                        newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[y].likedPost = votesFromCoreData.votesFromCoreDataArray[x].likedPost
                        newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[y].dislikedPost = votesFromCoreData.votesFromCoreDataArray[x].dislikedPost
                        
                        print("MATCH for \(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[y])")
                        print(votesFromCoreData.votesFromCoreDataArray[x])


                    } else {
                        print("No match for \(votesFromCoreData.votesFromCoreDataArray[x])")
                    }
                    
                }
                
            }
            
        } else if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count == 1  && votesFromCoreData.votesFromCoreDataArray.count == 1 {
            
            if votesFromCoreData.votesFromCoreDataArray[0].documentID == newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].documentID {
                
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].likedPost = votesFromCoreData.votesFromCoreDataArray[0].likedPost
                newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[0].dislikedPost = votesFromCoreData.votesFromCoreDataArray[0].dislikedPost
                
            }
            
        } else if newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count > 1  && votesFromCoreData.votesFromCoreDataArray.count == 1 {
            
            for x in 0...(newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray.count - 1) {
                
                if votesFromCoreData.votesFromCoreDataArray[0].documentID == newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].documentID {
                    
                    newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].likedPost = votesFromCoreData.votesFromCoreDataArray[0].likedPost
                    newlyFetchedNearbyPosts.newlyFetchedNearbyPostsArray[x].dislikedPost = votesFromCoreData.votesFromCoreDataArray[0].dislikedPost
                    
                }
                
                
            }
            
        }
        
    }
    
    func crosscheckCoreDataVotesToNewlyFetchedTrendingPosts() {
        
        if formattedTrendingPosts.formattedTrendingPostsArray.count == 1  && votesFromCoreData.votesFromCoreDataArray.count > 1 {
            
            for x in 0...(votesFromCoreData.votesFromCoreDataArray.count - 1) {
                
                if votesFromCoreData.votesFromCoreDataArray[x].documentID == formattedTrendingPosts.formattedTrendingPostsArray[0].documentID {
                    
                    formattedTrendingPosts.formattedTrendingPostsArray[0].likedPost = votesFromCoreData.votesFromCoreDataArray[x].likedPost
                    formattedTrendingPosts.formattedTrendingPostsArray[0].dislikedPost = votesFromCoreData.votesFromCoreDataArray[x].dislikedPost
                    
                }
                
            }
            
        } else if formattedTrendingPosts.formattedTrendingPostsArray.count > 1  && votesFromCoreData.votesFromCoreDataArray.count > 1 {
            
            for x in 0...(votesFromCoreData.votesFromCoreDataArray.count - 1) {
                
                for y in 0...(formattedTrendingPosts.formattedTrendingPostsArray.count - 1) {
                    
                    if votesFromCoreData.votesFromCoreDataArray[x].documentID == formattedTrendingPosts.formattedTrendingPostsArray[y].documentID {
                        
                        formattedTrendingPosts.formattedTrendingPostsArray[y].likedPost = votesFromCoreData.votesFromCoreDataArray[x].likedPost
                        formattedTrendingPosts.formattedTrendingPostsArray[y].dislikedPost = votesFromCoreData.votesFromCoreDataArray[x].dislikedPost
                        
                        print("MATCH for \(formattedTrendingPosts.formattedTrendingPostsArray[y])")
                        print(votesFromCoreData.votesFromCoreDataArray[x])


                    } else {
                        print("No match for \(votesFromCoreData.votesFromCoreDataArray[x])")
                    }
                    
                }
                
            }
            
        } else if formattedTrendingPosts.formattedTrendingPostsArray.count == 1  && votesFromCoreData.votesFromCoreDataArray.count == 1 {
            
            if votesFromCoreData.votesFromCoreDataArray[0].documentID == formattedTrendingPosts.formattedTrendingPostsArray[0].documentID {
                
                formattedTrendingPosts.formattedTrendingPostsArray[0].likedPost = votesFromCoreData.votesFromCoreDataArray[0].likedPost
                formattedTrendingPosts.formattedTrendingPostsArray[0].dislikedPost = votesFromCoreData.votesFromCoreDataArray[0].dislikedPost
                
            }
            
        } else if formattedTrendingPosts.formattedTrendingPostsArray.count > 1  && votesFromCoreData.votesFromCoreDataArray.count == 1 {
            
            for x in 0...(formattedTrendingPosts.formattedTrendingPostsArray.count - 1) {
                
                if votesFromCoreData.votesFromCoreDataArray[0].documentID == formattedTrendingPosts.formattedTrendingPostsArray[x].documentID {
                    
                    formattedTrendingPosts.formattedTrendingPostsArray[x].likedPost = votesFromCoreData.votesFromCoreDataArray[0].likedPost
                    formattedTrendingPosts.formattedTrendingPostsArray[x].dislikedPost = votesFromCoreData.votesFromCoreDataArray[0].dislikedPost
                    
                }
                
                
            }
            
        }
        
    }

}
