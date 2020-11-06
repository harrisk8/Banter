//
//  AppearAsViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 10/28/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

protocol updatePostingAsName {
    func updatePostingAsLabel()
    
}

class AppearAsViewController: UIViewController {
    
    
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    @IBOutlet weak var circle3: UIImageView!
    
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    var button1Selected = true
    var button2Selected = false
    var button3Selected = false
    
    var delegate: updatePostingAsName?

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        label1.text = "Incognito"
        label2.text = UserInfo.userAppearanceName
        label3.text = "Nickname"

        circle1.image = UIImage(named: "Checkmark Circle")
        circle2.image = UIImage(named: "Empty Checkmark Circle")
        circle3.image = UIImage(named: "Empty Checkmark Circle")


    }
    
    @IBAction func donePressed(_ sender: Any) {
        
        if button1Selected == true {
            print("Set name to incognito")
            UserInfo.userAppearanceName = "Incognito"
        } else if button2Selected == true {
            print("Set name to first name")
            UserInfo.userAppearanceName = "Harris"
        } else if button3Selected == true {
            print("Set name to nickname")
            UserInfo.userAppearanceName = "Nickname"
        }
        
        UserDefaults.standard.set(UserInfo.userAppearanceName, forKey: "lastUserAppearanceName")
        
        dismiss(animated: true, completion: nil)
        
        delegate?.updatePostingAsLabel()
        
    }
    
    @IBAction func button1Pressed(_ sender: Any) {
        print("Incognito")
        circle1.image = UIImage(named: "Checkmark Circle")
        circle2.image = UIImage(named: "Empty Checkmark Circle")
        circle3.image = UIImage(named: "Empty Checkmark Circle")
        
        button1Selected = true
        button2Selected = false
        button3Selected = false
    }
    
    
    
    @IBAction func button2Pressed(_ sender: Any) {
        print("Username")
        circle1.image = UIImage(named: "Empty Checkmark Circle")
        circle2.image = UIImage(named: "Checkmark Circle")
        circle3.image = UIImage(named: "Empty Checkmark Circle")
        
        button1Selected = false
        button2Selected = true
        button3Selected = false
    }
    
    
    @IBAction func button3Pressed(_ sender: Any) {
        print("Real name")
        circle1.image = UIImage(named: "Empty Checkmark Circle")
        circle2.image = UIImage(named: "Empty Checkmark Circle")
        circle3.image = UIImage(named: "Checkmark Circle")
        
        button1Selected = false
        button2Selected = false
        button3Selected = true
    }
    
 

}
