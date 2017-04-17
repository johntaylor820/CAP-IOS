//
//  LoginViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-03-24.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Crashlytics
import FBSDKLoginKit


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var loginState:String?

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorMasseageView: UIView!
    var errorMsgShowing = false
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var chopperHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMasseageView.layer.cornerRadius = 5
        chopperHeight.constant = 1/UIScreen.main.scale
        view.layoutIfNeeded()
        /*if FBSDKAccessToken.currentAccessToken() != nil {
            UserManager.sharedInstance.fetchFacebookUserInfo({ (user, error) in
                if let user = user {
                    self.handleSuccessfullyAuthenticatedWithUser(user)
                } else if let error = error {
                    debugPrint("FB Login: fetchFacebookUserInfo error: \( error.localizedDescription )")
                    // Logout if not successfully logged in
                    FBSDKLoginManager().logOut()
                }
            })
        }*/
//        if loginState == "facebook" {
//            UserManager.sharedInstance.loginWithFacebookLoginUI { (user, error) in
//                if let user = user {
//                    self.handleSuccessfullyAuthenticatedWithUser(user)
//                } else if let error = error {
//                    self.handleFailedAuthenticationWithError(error)
//                }
//            }
//        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "restorePW", sender: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            tryLogin()
        }
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
    }
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        tryLogin()
    }
    
    func tryLogin() {
        if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
        if usernameTextField.isFirstResponder {
            usernameTextField.resignFirstResponder()
        }
        guard let username = usernameTextField.text , username != "" else {
            showErrorWithText("You need to enter a username")
            return
        }
        
        guard let password = passwordTextField.text , password != "" else {
            showErrorWithText("You need to enter a password")
            return
        }
        UserManager.sharedInstance.authenticateWithUsername(username, password: password) { (user, error) in
            if let user = user {
                self.handleSuccessfullyAuthenticatedWithUser(user)
            } else if let error = error {
                self.handleFailedAuthenticationWithError(error as NSError)
            }
        }
    }
    
    fileprivate func handleSuccessfullyAuthenticatedWithUser(_ user: User) {
        DispatchQueue.main.async(execute: {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.navigateToApplication()
            }
        })
    }
    
    fileprivate func handleFailedAuthenticationWithError(_ error: NSError) {
        DispatchQueue.main.async(execute: {
            Crashlytics.sharedInstance().recordError(error)
            self.showErrorWithText("Unable to login.")
        })
    }
    
    @IBAction func errorButtonPressed(_ sender: UIButton) {
        hideErrorMsg()
    }
    
    func showErrorWithText(_ text:String) {
        errorMsgShowing = true
        errorMasseageView.isUserInteractionEnabled = true
        errorLabel.text = text
        UIView.animate(withDuration: 0.2, animations: {
            self.errorMasseageView.alpha = 1
            },completion: {finnised in
                self.delay()
        })
    }
    
    func delay() {
        let seconds = 2.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.hideErrorMsg()
            
        })
    }
    
    func hideErrorMsg() {
        errorMsgShowing = false
        errorMasseageView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, animations: {
            self.errorMasseageView.alpha = 0
        })
    }

}

