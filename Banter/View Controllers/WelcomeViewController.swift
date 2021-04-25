//
//  WelcomeViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 8/8/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseMessaging
import FirebaseAuth
import FirebaseDynamicLinks


class WelcomeViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var sliderView: UIView!
    

    @IBOutlet weak var emailFieldBackground: UIImageView!
    @IBOutlet weak var nextButtonSMSBackground: UIImageView!
    @IBOutlet weak var legalNoticeImage: UIImageView!
    
    @IBOutlet weak var phoneNumberPlaceholder: UILabel!
    @IBOutlet weak var pleaseEnterNumberLabel: UILabel!
    @IBOutlet weak var enterValidNumberPlease: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var keyboardHeight = 0.0
    
    var userPhoneNumber: String?
    
    var screenSlidedUp = false
    
    //Unwind segue will change this to true and pass back to this VC to perform a rapid screen slide upon screen appearance
    var backFromAuthCodeScreen = false
    
    let manager = CLLocationManager()

    var userEmail: String?
    var link: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            print("USER")
            print(Auth.auth().currentUser?.uid ?? nil)
            
            
        } else {
          // No user is signed in.
          // ...
        }
        
        emailTextField.delegate = self
                
        NotificationCenter.default.addObserver(self, selector: #selector(getKeyboardHeight(keyboardWillShowNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        manager.requestWhenInUseAuthorization()
        

        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
        }
        
        lookUpCurrentLocation(completionHandler: {_ in
            
            print("Location Obtained")
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {    
    }
    
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.manager.location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                    print((firstLocation?.locality ?? "") + (firstLocation?.administrativeArea ?? ""))
                    UserInfo.userCity = firstLocation?.locality ?? ""
                    UserInfo.userState = firstLocation?.administrativeArea ?? ""
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }

    
    //Validates and executes transition to next VC AND sends phone number for auth
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "welcomeScreenToAuthCodeScreen", sender: self)
        }
        
        if emailTextField.text != "" {

            if isValidEmail(userEmail: emailTextField.text!) == true && isValidEDUEmail() == true {
                sendLinkToEmail(validUserEmail: emailTextField.text!)
                self.performSegue(withIdentifier: "welcomeScreenToAuthCodeScreen", sender: self)
            } else {
                print("ERROR")
            }

        } else {
            print("ERROR")
        }
        
    }
    
    func sendLinkToEmail(validUserEmail: String) {
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://officialbanterapp.page.link/welcome")
        // The sign-in operation has to always be completed in the app.
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        Auth.auth().sendSignInLink(toEmail:validUserEmail,
                                   actionCodeSettings: actionCodeSettings) { error in
          // ...
            if let error = error {
              print(error.localizedDescription)
              return
            }
            // The link was successfully sent. Inform the user.
            // Save the email locally so you don't need to ask the user for it again
            // if they open the link on the same device.
            print("Link successfully sent")
            self.performSegue(withIdentifier: "welcomeScreenToAuthCodeScreen", sender: self)
            UserDefaults.standard.set(validUserEmail, forKey: "Email")
            // ...
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        slideScreenDown()
        emailTextField.resignFirstResponder()
    }

    
    func isValidEmail(userEmail:String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: userEmail)
    }
    
    func isValidEDUEmail() -> Bool {
        
        if let emailString = emailTextField.text {
            
            if emailString.count >= 7 {
                                
                let start = emailString.index(emailString.endIndex, offsetBy: -4)
                let end = emailString.index(emailString.endIndex, offsetBy: 0)
                let range = start..<end
                print(emailString[range])
                
                if emailString[range] == ".edu" {
                    print("The user entered a VALID email address")
                    return true
                } else {
                    print("The user entered an INVALID email address")
                    return false
                }
                
            } else {
                //User entered an invalid email (less than 7 characters)
                return false
            }
            
        }
        
        return false
    
    }
    
    
    
    
    //Passes user phone number and screen height to next VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let authCodeViewController = segue.destination as? AuthCodeViewController {
            authCodeViewController.userEmail = emailTextField.text
            authCodeViewController.keyboardHeight = keyboardHeight
            
        }
    }
    
    //Slides screen up and prepares for user to enter phone number
    @IBAction func emailFieldButtonPressed(_ sender: Any) {
        
        DispatchQueue.main.async {
            self.emailTextField.becomeFirstResponder()
            self.slideScreenUp()
        }
        phoneNumberButton.isUserInteractionEnabled = false
    }
    
    //Slides screen down if user pressed back button
    @IBAction func backButtonPressed(_ sender: Any) {
        
        DispatchQueue.main.async {
            self.slideScreenDown()
            self.emailTextField.resignFirstResponder()
        }
 
        phoneNumberButton.isUserInteractionEnabled = true
        enterValidNumberPlease.alpha = 0
    }
    

    //Handles functionality for "phone number" placeholder
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if emailTextField.text != "" {
            phoneNumberPlaceholder.alpha = 0
        } else {
            phoneNumberPlaceholder.alpha = 1
        }
    }
    

    //Functionality for screen slide up when user taps phone number field, makes room for keyboard
    func slideScreenUp() {
        screenSlidedUp = true
        phoneNumberButton.isUserInteractionEnabled = false
        nextButton.isUserInteractionEnabled = true
        self.sliderView.translatesAutoresizingMaskIntoConstraints = true
        self.emailFieldBackground.translatesAutoresizingMaskIntoConstraints = true
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = true
        self.enterValidNumberPlease.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, animations: {
            self.sliderView.frame.origin.y -= CGFloat(self.keyboardHeight)
            self.legalNoticeImage.alpha = 0
//            self.sliderView.alpha = 0
            self.backButton.alpha = 1
            self.nextButtonSMSBackground.alpha = 1
            self.view.frame.origin.y -= CGFloat(self.keyboardHeight)
            self.emailFieldBackground.frame.origin.y -= CGFloat(self.keyboardHeight * 0.55)
            self.emailTextField.frame.origin.y -= CGFloat(self.keyboardHeight * 0.55)
            self.phoneNumberPlaceholder.frame.origin.y -= CGFloat(self.keyboardHeight * 0.55)
            self.pleaseEnterNumberLabel.frame.origin.y -= CGFloat(self.keyboardHeight * 0.55)
            self.phoneNumberButton.frame.origin.y -= CGFloat(self.keyboardHeight * 0.55)
            self.enterValidNumberPlease.frame.origin.y -= CGFloat(self.keyboardHeight * 0.55)
        })
    }
    
    //Functionality for screen slide down when user taps back button. Simultaneous with resignation of text field.
    func slideScreenDown() {
        screenSlidedUp = false
        phoneNumberButton.isUserInteractionEnabled = true
        nextButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.legalNoticeImage.alpha = 1
            self.sliderView.frame.origin.y += CGFloat(self.keyboardHeight)
            self.sliderView.alpha = 1
            self.backButton.alpha = 0
            self.nextButtonSMSBackground.alpha = 0
            self.view.frame.origin.y += CGFloat(self.keyboardHeight)
            self.emailFieldBackground.frame.origin.y += CGFloat(self.keyboardHeight * 0.55)
            self.emailTextField.frame.origin.y += CGFloat(self.keyboardHeight * 0.55)
            self.phoneNumberPlaceholder.frame.origin.y += CGFloat(self.keyboardHeight * 0.55)
            self.pleaseEnterNumberLabel.frame.origin.y += CGFloat(self.keyboardHeight * 0.55)
            self.phoneNumberButton.frame.origin.y += CGFloat(self.keyboardHeight * 0.55)
            self.enterValidNumberPlease.frame.origin.y += CGFloat(self.keyboardHeight * 0.55)

            
        }
    }
    
    //Obtains height of keyboard allowing for view-sliding functionality for keyboard pop-up.
    @objc func getKeyboardHeight(keyboardWillShowNotification notification: Notification) {
        if let userInfo = notification.userInfo,
        let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = Double(keyboardSize.height)
            NotificationCenter.default.removeObserver(self)
        }
        print(keyboardHeight)
        UserInfo.keyboardHeight = keyboardHeight
    }
    
    
    //Limits phone number text field to 40 characters in length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = emailTextField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 40
    }
    
    //Benign function- necessary for unwind from next VC
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        
    }
    
    //Rapidly moves screen up after view appears from user pressing back on auth code screen
    override func viewDidAppear(_ animated: Bool) {
        if backFromAuthCodeScreen == true {
            emailTextField.becomeFirstResponder()
            slideScreenUp()
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -CGFloat(self.keyboardHeight)
            }
        }
    }
    
    @IBAction func swipedUp(_ sender: Any) {
        emailTextField.becomeFirstResponder()
        slideScreenUp()
        phoneNumberButton.isUserInteractionEnabled = false
    }
    
    @IBAction func swipedDown(_ sender: Any) {
        if screenSlidedUp == true {
            slideScreenDown()
            emailTextField.resignFirstResponder()
            phoneNumberButton.isUserInteractionEnabled = true
            enterValidNumberPlease.alpha = 0
        }
    }
    
    
}
