//
//  FinishSignUpViewController.swift
//  Mesh
//
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FinishSignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    
    
    @IBOutlet weak var joinButton: UIButton!
    
    
    var datePicker = UIDatePicker()
    
    var firstName = ""
    var dateOfBirth = ""
    
    var userDateOfBirth: Date?
    
    let database = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.delegate = self
        dateOfBirthTextField.delegate = self
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.sizeToFit()

        datePicker.addTarget(self, action:
            #selector(FinishSignUpViewController.dateChanged(datePicker:)),
            for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(FinishSignUpViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        dateOfBirthTextField.inputView = datePicker
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(FinishSignUpViewController.dismissPicker))
        dateOfBirthTextField.inputAccessoryView = toolBar
        
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.datePickerMode = .date
            datePicker.sizeToFit()
            }
        
        dateOfBirthTextField.inputView = datePicker
        
        firstNameTextField.attributedPlaceholder = NSAttributedString(string:"first name", attributes: [NSAttributedString.Key.foregroundColor:UIColor.init(red: 168.0/255.0, green: 168.0/255.0, blue: 168.0/255.0, alpha: 1),NSAttributedString.Key.backgroundColor:UIColor.clear])
        
        dateOfBirthTextField.attributedPlaceholder = NSAttributedString(string:"date of birth", attributes: [NSAttributedString.Key.foregroundColor:UIColor.init(red: 168.0/255.0, green: 168.0/255.0, blue: 168.0/255.0, alpha: 1),NSAttributedString.Key.backgroundColor:UIColor.clear])


        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.frame.origin.y = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firstNameTextField.becomeFirstResponder()
    }
    
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        
//        if validateUserInfo() {
//
//            print("User info is valid!")
//
//            UserDefaults.standard.set(firstNameTextField.text, forKey: "userFirstName")
//
//            if Auth.auth().isSignIn(withEmailLink: UserDefaults.standard.value(forKey: "Link") as! String) {
//
//                print("Now signing the user into Firebase")
//                Auth.auth().signIn(withEmail: UserDefaults.standard.value(forKey: "validUserEmail") as? String ?? "", link: UserDefaults.standard.value(forKey: "Link") as! String) { (user, error) in
//
//                    if error == nil {
//
//                        print("NO ERROR")
//
//                        print("The user signed in with userID below:")
//                        print(Auth.auth().currentUser?.uid)
//
//                        self.createNewUser()
//
//                    } else {
//                        print(error)
//                    }
//
//            }
//
//
//
//
//            }
//
//
//        } else {
//
//            print("Missing first name or DOB or both")
//        }
        
        verifyUserAge(dateOfBirth: datePicker.date)
        
    }
    
    
    //Writes user to database
    func createNewUser() {
                
        
        print("Trying to create user")
        
        let ref: DocumentReference? = nil
        database.collection("users").addDocument(data: [
            "userID": Auth.auth().currentUser?.uid ?? "",
            "first name": firstName,
            "date of birth": dateOfBirth
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                
                print("User Document Successfully created with documentID \(ref?.documentID ?? "ERROR FETCHING DOCUMENTID")")
                
                self.performSegue(withIdentifier: "finishSignUpToNearby", sender: self)
                
                UserInfo.userCollectionDocID = ref?.documentID
                UserInfo.userFirstName = self.firstNameTextField.text
                
                UserDefaults.standard.set(ref?.documentID, forKey: "userCollectionDocID")
                UserDefaults.standard.set(self.firstNameTextField.text, forKey: "userFirstName")
                UserDefaults.standard.set(true, forKey: "userAccountCreated")
                UserDefaults.standard.set("Incognito", forKey: "lastUserAppearanceName")
                
            }
        }
    }
    
    //Checks if all user info fields are good before allowing user to continue
    func validateUserInfo() -> Bool {
        
        var firstNameValid = false
        var dateOfBirthValid = false
        
        if firstNameTextField.text != "" {
            firstNameValid = true
        } else {
            print("First name missing")
            firstNameValid = false
        }
        
        
        if dateOfBirthTextField.text != "" {
            dateOfBirthValid = true
        } else {
            print("DOB missing")
            dateOfBirthValid = false
        }
        
        if firstNameValid == true && dateOfBirthValid == true {
            
            //Assigns textfield text to local variables
            firstName = firstNameTextField.text ?? ""
            dateOfBirth = dateOfBirthTextField.text ?? ""
            
            //Assigns textfield text to central variables
            UserInfo.userFirstName = firstName
            UserInfo.userDateOfBirth = dateOfBirth

            return true
            
        } else {
            
            return false
        }
        
    }
    


    //Handles placeholder functionality
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
    }
    
    
    //Handles functionality when user hits return. Validates current field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if firstNameTextField.text != "" && firstNameTextField.isFirstResponder == true {
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
        dateOfBirthTextField.inputView = datePicker
        
        dateOfBirthTextField.text = dateFormatter.string(from: datePicker.date)
        
        userDateOfBirth = datePicker.date

    }
    
    func verifyUserAge(dateOfBirth: Date) {
    
        let today = NSDate()
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let age = gregorian.components([.year], from: dateOfBirth, to: today as Date, options: [])

        if age.year ?? 0 < 18 {
                print("USER UNDER 18")
        } else {
            print("USER OVER 18")
        }
        

        
        
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

