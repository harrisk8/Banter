//
//  ProfileViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 12/6/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var currentlyAppearingAsLabel: UILabel!
    
    @IBOutlet weak var nicknameTextfield: UITextField!
    
    
    @IBOutlet weak var editNicknameButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nicknameTextfield.delegate = self
    
    }
    @IBAction func changeAppearanceNameButtonPressed(_ sender: Any) {
        
    }
    
    
    //Handles functionality for the nickname edit button
    @IBAction func editPressed(_ sender: Any) {
        //User is done editing nickname, validate then resign
        if nicknameTextfield.isFirstResponder == true {
            nicknameTextfield.resignFirstResponder()
            editNicknameButton.setImage(UIImage(named: "Edit Nickname Button"), for: .normal)
        } else {
            //User selected edit button
            nicknameTextfield.becomeFirstResponder()
            editNicknameButton.setImage(UIImage(named: "Done Button 2"), for: .normal)
        }
    }
    
    
    @IBAction func viewMyPostsButtonPressed(_ sender: Any) {
    }
    
    func validateNickname() -> Bool {
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
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
