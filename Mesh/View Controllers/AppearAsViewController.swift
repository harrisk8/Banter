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

protocol updateProfileLabel {
    
    func updateAppearingAsLabel()
    
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
    
    var profileDelegate: updateProfileLabel?

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        label1.text = "Incognito"
        label2.text = UserInfo.userAppearanceName
        if UserDefaults.standard.value(forKey: "userNickname") as? String ?? "" == "" {
            print(" - - - - No Nickname set! - - - - - ")
            label3.text = "Create name in Profile"
            label3.alpha = 0.35
            label3.font = UIFont(name: "Roboto-LightItalic", size: 15)
        } else {
            print(" - - - - Nickname set")
            label3.text = UserDefaults.standard.value(forKey: "userNickname") as? String
        }
        
        circle1.image = UIImage(named: "Empty Checkmark Circle")
        circle2.image = UIImage(named: "Empty Checkmark Circle")
        circle3.image = UIImage(named: "Empty Checkmark Circle")
        
        if UserDefaults.standard.value(forKey: "incognitoSelected") as? Bool == true {
            circle1.image = UIImage(named: "Checkmark Circle")
        } else if UserDefaults.standard.value(forKey: "firstNameSelected") as? Bool == true {
            circle2.image = UIImage(named: "Checkmark Circle")
        } else if UserDefaults.standard.value(forKey: "nicknameSelected") as? Bool == true &&                     UserDefaults.standard.value(forKey: "nicknameBlank") as? Bool == false {
            circle3.image = UIImage(named: "Checkmark Circle")
        } else {
            circle1.image = UIImage(named: "Checkmark Circle")
            UserDefaults.standard.set("Incognito", forKey: "lastUserAppearanceName")
            UserDefaults.standard.set(true, forKey: "incognitoSelected")
        }


    }
    
    @IBAction func donePressed(_ sender: Any) {
        
        if button1Selected == true {
            print("Set name to incognito")
            UserDefaults.standard.set("Incognito", forKey: "lastUserAppearanceName")
            UserDefaults.standard.set(true, forKey: "incognitoSelected")
            UserDefaults.standard.set(false, forKey: "firstNameSelected")
            UserDefaults.standard.set(false, forKey: "nicknameSelected")

        } else if button2Selected == true {
            print("Set name to first name")
            UserDefaults.standard.set(UserDefaults.standard.value(forKey: "userFirstName"), forKey: "lastUserAppearanceName")
            UserDefaults.standard.set(false, forKey: "incognitoSelected")
            UserDefaults.standard.set(true, forKey: "firstNameSelected")
            UserDefaults.standard.set(false, forKey: "nicknameSelected")

        } else if button3Selected == true {
            
            if UserDefaults.standard.value(forKey: "userNickname") as? String ?? "" == "" {
                print(" - - - - No Nickname set! - - - - - ")
            } else {
                print(" - - - - Nickname set - - - - - - ")
                print("Set name to nickname")
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "userNickname"), forKey: "lastUserAppearanceName")
                UserDefaults.standard.set(false, forKey: "incognitoSelected")
                UserDefaults.standard.set(false, forKey: "firstNameSelected")
                UserDefaults.standard.set(true, forKey: "nicknameSelected")
                
            }
            
        }
                
        dismiss(animated: true, completion: nil)
        
        delegate?.updatePostingAsLabel()
        
        profileDelegate?.updateAppearingAsLabel()
        
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
        
        if UserDefaults.standard.value(forKey: "userNickname") as? String ?? "" == "" {
            print(" - - - - No Nickname set! - - - - - ")
        } else {
            print(" - - - - Nickname set - - - - - - ")
            circle1.image = UIImage(named: "Empty Checkmark Circle")
            circle2.image = UIImage(named: "Empty Checkmark Circle")
            circle3.image = UIImage(named: "Checkmark Circle")
            
            button1Selected = false
            button2Selected = false
            button3Selected = true
            
        }
    }
    
    
 

}
