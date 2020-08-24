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


class WelcomeViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var sliderView: UIView!
    
    @IBOutlet weak var phoneNumberBackground: UIImageView!
    @IBOutlet weak var nextButtonSMSBackground: UIImageView!
    @IBOutlet weak var legalNoticeImage: UIImageView!
    
    @IBOutlet weak var phoneNumberPlaceholder: UILabel!
    @IBOutlet weak var pleaseEnterNumberLabel: UILabel!
    @IBOutlet weak var enterValidNumberPlease: UILabel!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var keyboardHeight = 0.0
    
    var userPhoneNumber: String?
    
    //Unwind segue will change this to true and pass back to this VC to perform a rapid screen slide upon screen appearance
    var backFromAuthCodeScreen = false
    
    let manager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.delegate = self
                
        NotificationCenter.default.addObserver(self, selector: #selector(getKeyboardHeight(keyboardWillShowNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        manager.requestWhenInUseAuthorization()
        

        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
        }
        
        lookUpCurrentLocation(completionHandler: {_ in
            
            print("HI")
        })

        makeTestArray()

        // Do any additional setup after loading the view.
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
    
    func makeTestArray() {
        
        for _ in 1...10 {
            let newCell = NearbyCellData(author: "Harris", message: "The quick brown fox jumped over the lazy dog.")
            NearbyArray.nearbyArray.append(newCell)
        }

    }
    
    
    
    
    //Validates and executes transition to next VC AND sends phone number for auth
    @IBAction func nextButtonPressed(_ sender: Any) {
        if validatePhoneNumber() {
            print("Phone # is good")
            verifyPhoneNumber()
            performSegue(withIdentifier: "welcomeScreenToAuthCodeScreen", sender: self)
        } else {
            print("Phone # is BAD")
            enterValidNumberPlease.alpha = 1
        }
        
    }
    
    func verifyPhoneNumber() {
        
        PhoneAuthProvider.provider().verifyPhoneNumber("+19548645827", uiDelegate: nil) {
            (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            UserDefaults.standard.set(verificationID ?? "", forKey: "authVerificationID")
   
        }
        
    }
    
    
    
    
    
    
    //Passes user phone number and screen height to next VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let authCodeViewController = segue.destination as? AuthCodeViewController {
            authCodeViewController.phoneNumber = phoneNumberTextField.text
            authCodeViewController.keyboardHeight = keyboardHeight
        }
    }
    
    //Slides screen up and prepares for user to enter phone number
    @IBAction func phoneNumberButtonPressed(_ sender: Any) {
        phoneNumberTextField.becomeFirstResponder()
        slideScreenUp()
        phoneNumberButton.isUserInteractionEnabled = false
    }
    
    //Slides screen down if user pressed back button
    @IBAction func backButtonPressed(_ sender: Any) {
        slideScreenDown()
        phoneNumberTextField.resignFirstResponder()
        phoneNumberButton.isUserInteractionEnabled = true
        enterValidNumberPlease.alpha = 0
    }
    

    //Handles functionality for "phone number" placeholder
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if phoneNumberTextField.text != "" {
            phoneNumberPlaceholder.alpha = 0
        } else {
            phoneNumberPlaceholder.alpha = 1
        }
    }
    

    //Functionality for screen slide up when user taps phone number field, makes room for keyboard
    func slideScreenUp() {
        phoneNumberButton.isUserInteractionEnabled = false
        nextButton.isUserInteractionEnabled = true
        self.sliderView.translatesAutoresizingMaskIntoConstraints = true
        self.phoneNumberBackground.translatesAutoresizingMaskIntoConstraints = true
        self.phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = true
        self.enterValidNumberPlease.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.3) {
            self.sliderView.frame.origin.y -= CGFloat(self.keyboardHeight)
            self.legalNoticeImage.alpha = 0
            self.sliderView.alpha = 0
            self.backButton.alpha = 1
            self.nextButtonSMSBackground.alpha = 1
            self.view.frame.origin.y -= CGFloat(self.keyboardHeight)
            self.phoneNumberBackground.frame.origin.y -= CGFloat(self.keyboardHeight * 0.65)
            self.phoneNumberTextField.frame.origin.y -= CGFloat(self.keyboardHeight * 0.65)
            self.phoneNumberPlaceholder.frame.origin.y -= CGFloat(self.keyboardHeight * 0.65)
            self.pleaseEnterNumberLabel.frame.origin.y -= CGFloat(self.keyboardHeight * 0.65)
            self.phoneNumberButton.frame.origin.y -= CGFloat(self.keyboardHeight * 0.65)
            self.enterValidNumberPlease.frame.origin.y -= CGFloat(self.keyboardHeight * 0.65)

        }
    }
    
    //Functionality for screen slide down when user taps back button. Simultaneous with resignation of text field.
    func slideScreenDown() {
        phoneNumberButton.isUserInteractionEnabled = true
        nextButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.legalNoticeImage.alpha = 1
            self.sliderView.frame.origin.y += CGFloat(self.keyboardHeight)
            self.sliderView.alpha = 1
            self.backButton.alpha = 0
            self.nextButtonSMSBackground.alpha = 0
            self.view.frame.origin.y += CGFloat(self.keyboardHeight)
            self.phoneNumberBackground.frame.origin.y += CGFloat(self.keyboardHeight * 0.65)
            self.phoneNumberTextField.frame.origin.y += CGFloat(self.keyboardHeight * 0.65)
            self.phoneNumberPlaceholder.frame.origin.y += CGFloat(self.keyboardHeight * 0.65)
            self.pleaseEnterNumberLabel.frame.origin.y += CGFloat(self.keyboardHeight * 0.65)
            self.phoneNumberButton.frame.origin.y += CGFloat(self.keyboardHeight * 0.65)
            self.enterValidNumberPlease.frame.origin.y += CGFloat(self.keyboardHeight * 0.65)

            
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
    }
    
    //Validates whether user entered complete number. Gateway for segue
    func validatePhoneNumber() -> Bool {
        if let phoneNumberEntry = phoneNumberTextField.text {
            if phoneNumberEntry.count == 10 {
                userPhoneNumber = "+1" + phoneNumberTextField.text!
                print(userPhoneNumber!)
                return true
            }
        }
        return false
    }
    
    //Limits phone number text field to 10 characters in length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = phoneNumberTextField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 10
    }
    
    //Benign function- necessary for unwind from next VC
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        
    }
    
    //Rapidly moves screen up after view appears from user pressing back on auth code screen
    override func viewDidAppear(_ animated: Bool) {
        if backFromAuthCodeScreen == true {
            phoneNumberTextField.becomeFirstResponder()
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -CGFloat(self.keyboardHeight)
            }
        }
    }
    

    
    
}
