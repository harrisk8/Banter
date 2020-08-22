//
//  FinishSignUpViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/21/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class FinishSignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    
    @IBOutlet weak var firstNamePlaceholder: UILabel!
    @IBOutlet weak var lastNamePlaceholder: UILabel!
    @IBOutlet weak var dateOfBirthPlaceholder: UILabel!
    
    private var datePicker: UIDatePicker?

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
    
    //Handles functionality when user hits return. Validates current field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if firstNameTextField.text != "" && firstNameTextField.isFirstResponder == true {
            lastNameTextField.becomeFirstResponder()
            print("testgood")
            return true
        }
        if lastNameTextField.text != "" && lastNameTextField.isFirstResponder == true {
            dateOfBirthTextField.becomeFirstResponder()
            print("asfd")
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

