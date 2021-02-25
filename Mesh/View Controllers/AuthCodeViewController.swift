//
//  AuthCodeViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/15/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase

class AuthCodeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var digit1: UITextField!
    @IBOutlet weak var digit2: UITextField!
    @IBOutlet weak var digit3: UITextField!
    @IBOutlet weak var digit4: UITextField!
    @IBOutlet weak var digit5: UITextField!
    @IBOutlet weak var digit6: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resendCodeButton: UIButton!
    
    
    @IBOutlet weak var instructions: UILabel!
    
    var phoneNumber: String?
    var authCode: String?
    
    let database = Firestore.firestore()

    var keyboardHeight: Double?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        digit1.delegate = self
        digit2.delegate = self
        digit3.delegate = self
        digit4.delegate = self
        digit5.delegate = self
        digit6.delegate = self
        
        digit1.becomeFirstResponder()
        
        print(phoneNumber!)
        print(keyboardHeight!)
        
        organizeInstructions()
        organizeResendButton()

    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        print("next pressed")
        if validateCode() {
            print("Sufficient digits")
            verifyAuthCode()
        } else {
            print("Bad code")
        }
    
    }
    
    
    func verifyAuthCode() {
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: authCode ?? "")
        
        Auth.auth().signIn(with: credential, completion: { authData, error in
            if let error = error {
                print(error.localizedDescription)
                print("INCORRECT CODE TRY AGAIN")
            } else {
                print(Auth.auth().currentUser?.uid ?? "")
                
                //Stores userID in UserInfo class for local usage
                UserInfo.userID = Auth.auth().currentUser?.uid ?? ""
                
                self.getUserDocID()
                
                
            }
            
        })
        
    }
    
    func getUserDocID() {
        
        
        print("trying to get doc)")
        
        database.collection("users").whereField("userID", isEqualTo: UserInfo.userID ?? "").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print(err.localizedDescription)
                print(" - - - - THIS USER DOES NOT EXIST YET - - - - ")
                self.performSegue(withIdentifier: "authCodeScreenToFinishSignUpScreen", sender: self)
            } else {
                
                if querySnapshot!.documents.count == 0 {
                    
                    print(" - - - - THIS USER DOES NOT EXIST YET - - - - ")
                    self.performSegue(withIdentifier: "authCodeScreenToFinishSignUpScreen", sender: self)
                    
                } else {
                    
                    print("User exists")
                    
                    for document in querySnapshot!.documents {
                        
                        let postData = document.data()
                        
                        if let postID = document.documentID as String? {
                            
                            UserInfo.userCollectionDocID = postID
                            print(" - - - - - Existing user with userDocID: - - - - - - ")
                            print(postID)
                            UserDefaults.standard.set(postID, forKey: "userCollectionDocID")
                            UserDefaults.standard.set(true, forKey: "userAccountCreated")
                            self.performSegue(withIdentifier: "existingUserAuthToNearby", sender: self)
                        
                        }
                    }
                    
                    
                }
                

            }
        }
        
    }
    
    
    //Returns user to welcome screen
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindAuthCodeToWelcome", sender: self)
    
    }
    
    @IBAction func resendCodePressed(_ sender: Any) {
        print("Resend Code")
    }
    
    
    //Ensures proper slide visual when user clicks back
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let welcomeViewController = segue.destination as? WelcomeViewController {
            welcomeViewController.backFromAuthCodeScreen = true
        }
    }
    
    
    
    
    //Manages screen slide functionality automatically upon segue
    override func viewWillLayoutSubviews() {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -CGFloat(self.keyboardHeight ?? 0.0)
        }
    }
    
    //Keeps keyboard active if reCAPTCHA verification opens window
    override func viewDidAppear(_ animated: Bool) {
        digit1.becomeFirstResponder()
    }
    
    //Adds forward transition functionality to six separate text fields for security code entry
    func textFieldDidChangeSelection(_ textField: UITextField) {
                
        let code1 = digit1.text ?? ""
        let code2 = digit2.text ?? ""
        let code3 = digit3.text ?? ""
        let code4 = digit4.text ?? ""
        let code5 = digit5.text ?? ""
        let code6 = digit6.text ?? ""
        
        if code1 != "" && code2 == "" {
            digit2.isUserInteractionEnabled = true
            digit2.becomeFirstResponder()
            digit1.isUserInteractionEnabled = false
        } else if code1 != "" && code2 != "" && code3 == "" {
            digit3.isUserInteractionEnabled = true
            digit3.becomeFirstResponder()
            digit2.isUserInteractionEnabled = false
        } else if code1 != "" && code2 != "" && code3 != "" && code4 == "" {
            digit4.isUserInteractionEnabled = true
            digit4.becomeFirstResponder()
            digit3.isUserInteractionEnabled = false
        } else if code1 != "" && code2 != "" && code3 != "" && code4 != "" && code5 == "" {
            digit5.isUserInteractionEnabled = true
            digit5.becomeFirstResponder()
            digit4.isUserInteractionEnabled = false
        } else if code1 != "" && code2 != "" && code3 != "" && code4 != "" && code5 != "" && code6 == "" {
            digit6.isUserInteractionEnabled = true
            digit6.becomeFirstResponder()
            digit5.isUserInteractionEnabled = false
        }
    }
    
    //Adds backwards transition functionality to six separate text fields for security code entry
    @objc func keyboardInputShouldDelete(_ textField: UITextField) -> Bool {
        
        let code1 = digit1.text ?? ""
        let code2 = digit2.text ?? ""
        let code3 = digit3.text ?? ""
        let code4 = digit4.text ?? ""
        let code5 = digit5.text ?? ""
        let code6 = digit6.text ?? ""
        
        if code1 != "" && code2 != "" && code3 != "" && code4 != "" && code5 != "" && code6 != "" {
            return true
        } else if code1 != "" && code2 != "" && code3 != "" && code4 != "" && code5 != "" && code6 == "" {
            digit5.isUserInteractionEnabled = true
            digit5.becomeFirstResponder()
            digit6.isUserInteractionEnabled = false
        } else if code1 != "" && code2 != "" && code3 != "" && code4 != "" && code5 == "" {
            digit4.isUserInteractionEnabled = true
            digit4.becomeFirstResponder()
            digit5.isUserInteractionEnabled = false
        } else if code1 != "" && code2 != "" && code3 != "" && code4 == "" {
            digit3.isUserInteractionEnabled = true
            digit3.becomeFirstResponder()
            digit4.isUserInteractionEnabled = false
        } else if code1 != "" && code2 != "" && code3 == "" {
            digit2.isUserInteractionEnabled = true
            digit2.becomeFirstResponder()
            digit3.isUserInteractionEnabled = false
        } else if code1 != "" && code2 == "" {
            digit1.isUserInteractionEnabled = true
            digit1.becomeFirstResponder()
            digit2.isUserInteractionEnabled = false
        }
        return true
    }
    
    func validateCode() -> Bool {
        if digit1.text != "" && digit2.text != "" && digit3.text != "" && digit4.text != "" && digit5.text != "" && digit6.text != "" {
            authCode = ("\(digit1.text ?? "")\(digit2.text ?? "")\(digit3.text ?? "")\(digit4.text ?? "")\(digit5.text ?? "")\(digit6.text ?? "")")
            print(authCode!)
            return true
        }
        return false
    }
    
    func organizeInstructions() {
        
        let instructionsPartOne = NSMutableAttributedString(string: "Please enter the 6-digit code that was sent to: ")
        let instructionsPartTwo = organizeNumber(unorganizedPhoneNumber: phoneNumber ?? "")
        
        let phoneNumberAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Roboto-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        ]
        
        let attributedPhoneNumber = NSMutableAttributedString(string: instructionsPartTwo, attributes: phoneNumberAttributes)

        instructionsPartOne.append(attributedPhoneNumber)
        
        instructions.adjustsFontSizeToFitWidth = true
        instructions.attributedText = instructionsPartOne
                
        
    }
    
    //Code is necessary to have button title with bold text
    func organizeResendButton() {
        
        let resendCodeAttributes: [NSAttributedString.Key: Any] = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "Roboto-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        ]
    
        let attributedResendCodeTitle = NSMutableAttributedString(string: "Resend Code", attributes: resendCodeAttributes)
            
        resendCodeButton.setAttributedTitle(attributedResendCodeTitle, for: .normal)
        
        resendCodeButton.titleLabel?.adjustsFontSizeToFitWidth = true

    }
    
    //Format user number with dashes
    func organizeNumber(unorganizedPhoneNumber: String) -> String {
        return (unorganizedPhoneNumber[0..<3] + "-" + unorganizedPhoneNumber[3..<6] + "-" + unorganizedPhoneNumber[6..<10])
    }
    
    //Limits each individual textfield entry to 1
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    
    
}

//Allows functionality to organize phone number
extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }

}


