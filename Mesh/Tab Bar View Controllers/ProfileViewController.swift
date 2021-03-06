//
//  ProfileViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 12/6/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate, updatePostingAsName {
    
    
    func updatePostingAsLabel() {
        print("REC")
    }
    

    
    @IBOutlet weak var currentlyAppearingAsLabel: UILabel!
    
    @IBOutlet weak var nicknameErrorLabel: UILabel!
    
    @IBOutlet weak var nicknameTextfield: UITextField!
    
    @IBOutlet weak var editNicknameButton: UIButton!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nicknameTextfield.delegate = self
        
        nicknameErrorLabel.alpha = 0
        
        currentlyAppearingAsLabel.text = UserDefaults.standard.string(forKey: "lastUserAppearanceName")
//        currentlyAppearingAsLabel.text = UserDefaults.standard.value(forKey: "lastUserAppearanceName") as? String
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
    
    }
    
    @IBAction func changeAppearanceNameButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "profileToChangeName", sender: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @objc func DismissKeyboard(){

        if validateNickname() == true {
            editNicknameButton.setImage(UIImage(named: "Edit Nickname Button"), for: .normal)
            nicknameErrorLabel.alpha = 0
            view.endEditing(true)
        } else {
            nicknameErrorLabel.alpha = 1
        }

    //Causes the view to resign from the status of first responder.
    }
 
    //Handles functionality for the nickname edit button
    @IBAction func editPressed(_ sender: Any) {
        //User is done editing nickname, validate then resign
        if nicknameTextfield.isFirstResponder == true {
            
            if validateNickname() {
                
                nicknameTextfield.resignFirstResponder()
                nicknameErrorLabel.alpha = 0
                editNicknameButton.setImage(UIImage(named: "Edit Nickname Button"), for: .normal)
                UserDefaults.standard.set(false, forKey: "nicknameBlank")

                
                if nicknameTextfield.text == "" {
                    
                    UserDefaults.standard.set("", forKey: "userNickname")
                    UserDefaults.standard.set(true, forKey: "nicknameBlank")

                    
                } else {
                    
                    UserDefaults.standard.set(nicknameTextfield.text, forKey: "userNickname")
                }
                
            } else {
                
                print(" - - - INVALID USERNAME - - - - - -")
            }
            
        } else {
            //User selected edit button
            nicknameTextfield.becomeFirstResponder()
            editNicknameButton.setImage(UIImage(named: "Done Button 2"), for: .normal)
        }
    }
    
    
    @IBAction func viewMyPostsButtonPressed(_ sender: Any) {
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editNicknameButton.setImage(UIImage(named: "Done Button 2"), for: .normal)
        
    }
    
    func validateNickname() -> Bool {
        
        if let nickname = nicknameTextfield.text {
            
            if nickname.count >= 4 {
                return true
            } else if nickname.count == 0 {
                return true
            } else {
                nicknameErrorLabel.alpha = 1
            }
        }
        return false
    }
    
    //Limits phone number text field to 10 characters in length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = nicknameTextfield.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 14
    }
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let nickname = nicknameTextfield.text {
            if nickname.count >= 4 {
                nicknameErrorLabel.alpha = 0
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if validateNickname() {
            return true
        } else {
            return false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTransparentNavigationBarWithWhiteText()
    }
    

    override func viewDidLayoutSubviews() {
        
        
        
    }

 

}



extension UIViewController {
    func setupTransparentNavigationBarWithBlackText() {
        setupTransparentNavigationBar()
        //Status bar text and back(item) tint to black
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.tintColor = .black
    }

    func setupTransparentNavigationBarWithWhiteText() {
        setupTransparentNavigationBar()
        //Status bar text and back(item) tint to white
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.tintColor = .white
    }

    func setupTransparentNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.isTranslucent = true
    }
}

