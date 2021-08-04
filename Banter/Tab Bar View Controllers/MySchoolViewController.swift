//
//  MySchoolViewController.swift
//  Banter
//
//  Created by Harris Kapoor on 8/2/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import UIKit

class MySchoolViewController: UIViewController {
    
    @IBOutlet weak var addMySchoolButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        switch UserInfo.hasUserAddedSchool {
        
        case .userHasAddedSchool:
            //Present table view of user's school's posts
            print("User has added school")

        case .userHasNotAddedSchool:
            //Present user with prompt and button to add school
            print("User has not added school")

        case .none:
            print("User has not added school")

        }
        
    }
    
    //Configures UI for user that HAS added their school. This will disable the "Add my school" button in the interface and set the alpha of both the prompt and button to 0, while presenting the table view of posts near the user's school.
    func userHadAddedSchoolSetup() {
        
    }
    
    //Configures UI for user that HAS NOT added their school. This will disable/set alpha of table view to 0, while presenting button and prompt for the user to add their school.
    func userHasNotAddedSchoolSetup() {
        
    }
    

    //Segues to school selection VC when button pressed
    @IBAction func addMySchoolButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "mySchoolToAddMySchool", sender: self)
    }
    
    
    

}
