//
//  ConfirmSchoolViewController.swift
//  Banter
//
//  Created by Harris Kapoor on 8/4/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ConfirmSchoolViewController: UIViewController {
    
    @IBOutlet weak var schoolNameLabel: UILabel!
    
    var schoolName: String?
    
    let database = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        schoolNameLabel.text = schoolName
        

    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        
//        let databaseRef = database.collection("users").document(UserInfo.userCollectionDocID ?? "")
//
//        databaseRef.updateData([
//
//            "userSchool": schoolName!
//
//        ]) { err in
//            if let err = err {
//                print(err.localizedDescription)
//            } else {
//                print("Document successfully written")
//            }
//        }
        
        performSegue(withIdentifier: "unwindToMySchool", sender: self)
        
        UserDefaults.standard.setValue(true, forKey: "hasUserAddedSchool")
        UserDefaults.standard.setValue(schoolName, forKey: "userSchool")
        UserInfo.userSchool = schoolName
        UserInfo.hasUserAddedSchool = .userHasAddedSchool

        
    }

    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
