//
//  AuthCodeViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/15/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDynamicLinks


class AuthCodeViewController: UIViewController, UITextFieldDelegate, userAuthenticated {
    
    func successfulAuth() {
        
        print("WE GOT THE AUTH")
        DispatchQueue.main.async {
            self.successfulVerificationLabel.alpha = 1.0
            self.performSegue(withIdentifier: "authCodeScreenToFinishSignUpScreen", sender: self)
        }
    }
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resendCodeButton: UIButton!
    
    
    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var successfulVerificationLabel: UILabel!
    
    var userEmail: String?
    var authCode: String?
    
    let database = Firestore.firestore()

    var keyboardHeight: Double?
    
    var link: String?
    
    var authStataDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        resendCodeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        print(userEmail!)
        print(keyboardHeight!)
        
        organizeInstructions()
        organizeResendButton()

        
        if let link = UserDefaults.standard.value(forKey: "Link") as? String {
              self.link = link
            }
        
        SceneDelegate.authNotificationDelegate = self

        
    }
    
    override func viewWillLayoutSubviews() {
        self.view.frame.origin.y = 0

    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    

    

    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "authCodeScreenToFinishSignUpScreen", sender: self)

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
                        
                        if let postID = document.documentID as String?,
                            let userFirstName = postData["first name"] as? String
                            
                            {
                                
                                print(" - - - - - Existing user with userDocID: - - - - - - ")
                                print(postID)
                                print(" - - - First Name - - - - ")
                                print(userFirstName)
                                UserInfo.userCollectionDocID = postID
                                UserInfo.userFirstName = userFirstName
                                UserDefaults.standard.set(postID, forKey: "userCollectionDocID")
                                UserDefaults.standard.set(userFirstName, forKey: "userFirstName")
                                UserDefaults.standard.set(true, forKey: "userAccountCreated")
                                UserDefaults.standard.set("Incognito", forKey: "lastUserAppearanceName")
                                UserDefaults.standard.set(true, forKey: "incognitoSelected")
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
        
        Auth.auth().currentUser?.reload()
        
        Auth.auth().currentUser?.reload(completion: { Error in
            print("userssignedin")
        })

        
//        print("Resend Code")
//
//        // Get link url string from the dynamic link captured in AppDelegate.
//        if let link = UserDefaults.standard.value(forKey: "Link") as? String {
//            self.link = link
//        }
//
//        // Sign user in with the link and email.
//        Auth.auth().signIn(withEmail: userEmail ?? "", link: link ?? "NO LINK") { (result, error) in
//
//            if error == nil && result != nil {
//
//                if (Auth.auth().currentUser?.isEmailVerified)! {
//                    print("User verified with passwordless email")
//
//                    // TODO: Do something after user verified like present a new View Controller
//
//                }
//                else {
//                    print("User NOT verified by passwordless email")
//
//                }
//            }
//            else {
//                print("Error with passwordless email verfification: \(error?.localizedDescription ?? "Strangely, no error avaialble.")")
//            }
//        }
        
    }
    
    
    //Ensures proper slide visual when user clicks back
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let welcomeViewController = segue.destination as? WelcomeViewController {
            welcomeViewController.backFromAuthCodeScreen = true
        }
    }
    
    
//    Keeps keyboard active if reCAPTCHA verification opens window
    override func viewDidAppear(_ animated: Bool) {
        
        
        Auth.auth().currentUser?.reload()
        
        Auth.auth().currentUser?.reload(completion: { Error in
            print("userssignedin")
        })
        

        print(UserDefaults.standard.value(forKey: "Link"))

        authStataDidChangeListenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            if user == nil {
                print("User not signed in")
            }
            if let user = user, let email = user.email {
                print(Auth.auth().currentUser?.uid)
                print("User signed in")

            }
        })

    }
    
    
    func organizeInstructions() {
        
        let instructionsPartOne = NSMutableAttributedString(string: "Please click the verification link that was sent to: ")
        let instructionsPartTwo = userEmail ?? ""
        
        let phoneNumberAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Roboto-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
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
    

    
    
    
    
}



