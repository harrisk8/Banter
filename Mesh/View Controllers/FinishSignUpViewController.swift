//
//  FinishSignUpViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/21/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase

class FinishSignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    
    @IBOutlet weak var firstNamePlaceholder: UILabel!
    @IBOutlet weak var lastNamePlaceholder: UILabel!
    @IBOutlet weak var dateOfBirthPlaceholder: UILabel!
    
    private var datePicker: UIDatePicker?
    
    var firstName = ""
    var lastName = ""
    var dateOfBirth = ""
    
    
    let database = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        dateOfBirthTextField.delegate = self
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action:
            #selector(FinishSignUpViewController.dateChanged(datePicker:)),
            for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(FinishSignUpViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        dateOfBirthTextField.inputView = datePicker
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(FinishSignUpViewController.dismissPicker))
        dateOfBirthTextField.inputAccessoryView = toolBar
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firstNameTextField.becomeFirstResponder()
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        
        if validateUserInfo() {
            print("CONTINUE")
            createNewUser()
            performSegue(withIdentifier: "finishSignUpToNearby", sender: self)
        } else {
            print("MISSING INFO")
        }
    }
    
    //Writes user to database
    func createNewUser() {
        
        let ref: DocumentReference? = nil
        database.collection("users").addDocument(data: [
            "userID": Auth.auth().currentUser?.uid ?? "",
            "first name": firstName,
            "last name": lastName,
            "date of birth": dateOfBirth
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("Document successfully written")
                print("USER DOC ID:")
                print(ref?.documentID)
                UserDefaults.standard.set(ref?.documentID, forKey: "userCollectionDocID")
                UserDefaults.standard.set(true, forKey: "userAccountCreated")
            }
        }
    }
    
    //Checks if all user info fields are good before allowing user to continue
    func validateUserInfo() -> Bool {
        
        var firstNameValid = false
        var lastNameValid = false
        var dateOfBirthValid = false
        
        if firstNameTextField.text != "" {
            firstNameValid = true
        } else {
            print("First name missing")
        }
        
        if lastNameTextField.text != "" {
            lastNameValid = true
        } else {
            print("Last name missing")
        }
        
        if dateOfBirthTextField.text != "" {
            dateOfBirthValid = true
        } else {
            print("DOB missing")
        }
        
        if firstNameTextField.text != "" && lastNameTextField.text != "" && dateOfBirthTextField.text != "" {
            print("Information valid")
        }
        
        if firstNameValid == true && lastNameValid == true && dateOfBirthValid == true {
            
            //Assigns textfield text to local variables
            firstName = firstNameTextField.text ?? ""
            lastName = lastNameTextField.text ?? ""
            dateOfBirth = dateOfBirthTextField.text ?? ""
            
            //Assigns textfield text to central variables
            UserInfo.userFirstName = firstName
            UserInfo.userLastName = lastName
            UserInfo.userDateOfBirth = dateOfBirth

            return true
        } else {
            return false
        }
        
    }
    


    //Handles placeholder functionality
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if firstNameTextField.text != "" {
            firstNamePlaceholder.alpha = 0
            
        } else if firstNameTextField.text == "" {
            firstNamePlaceholder.alpha = 1
        }
        
        if lastNameTextField.text != "" {
            lastNamePlaceholder.alpha = 0
        } else if lastNameTextField.text == "" {
            lastNamePlaceholder.alpha = 1
        }
        
        if dateOfBirthTextField.text != "" {
            dateOfBirthPlaceholder.alpha = 0
        } else if dateOfBirthTextField.text == "" {
            dateOfBirthPlaceholder.alpha = 1
        }
        
    }
    
    
    //Handles functionality when user hits return. Validates current field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if firstNameTextField.text != "" && firstNameTextField.isFirstResponder == true {
            lastNameTextField.becomeFirstResponder()
            return true
        }
        if lastNameTextField.text != "" && lastNameTextField.isFirstResponder == true {
            dateOfBirthTextField.becomeFirstResponder()
            return true
        }
        if dateOfBirthTextField.text != "" && dateOfBirthTextField.isFirstResponder == true {
            dateOfBirthTextField.resignFirstResponder()
            return true
        }
        return false
    }

    
    
    //Following 3 functions handle date picker functionality
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        }
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateOfBirthTextField.text = dateFormatter.string(from: datePicker.date)
        
    }


}

//DOB Toolbar w/ "Done" button
extension UIToolbar {

func ToolbarPiker(mySelect : Selector) -> UIToolbar {

    let toolBar = UIToolbar()

    toolBar.barStyle = UIBarStyle.default
    toolBar.isTranslucent = true
    toolBar.tintColor = UIColor.white
    toolBar.sizeToFit()

    let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

    toolBar.setItems([ spaceButton, doneButton], animated: false)
    toolBar.isUserInteractionEnabled = true

    return toolBar
}

}

