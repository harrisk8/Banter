//
//  ConfirmSchoolViewController.swift
//  Banter
//
//  Created by Harris Kapoor on 8/4/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import UIKit

class ConfirmSchoolViewController: UIViewController {
    
    @IBOutlet weak var schoolNameLabel: UILabel!
    
    var schoolName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        schoolNameLabel.text = schoolName
        

    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
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
