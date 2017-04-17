//
//  ChangePasswordViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-13.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Crashlytics

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorMessageView: UIView!
    var errorMsgShowing = false

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    
    @IBOutlet weak var chopperHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessageView.layer.cornerRadius = 5
        chopperHeight.constant = 1/UIScreen.main.scale

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        updatePassword()
    }

    func updatePassword() {
        guard let currentPassword = passwordTextField.text , currentPassword.characters.count > 0 else {
            showErrorWithText("You need to enter a password")
            return
        }
        guard let password = passwordAgainTextField.text , password != "" else {
            showErrorWithText("You need to enter a password")
            return
        }
        
        guard let password2 = passwordTextField.text , password == password2 else {
            showErrorWithText("Passwords don't match")
            return
        }
        UserManager.sharedInstance.changeUserPassword(currentPassword, newPassword: password, completion: { (success, error) in
            if success {
                self.handleSuccessfullyAuthenticatedWithUser()
            } else if let error = error {
                self.handleFailedAuthenticationWithError(error as NSError)
            }
        })
    }
    
    fileprivate func handleSuccessfullyAuthenticatedWithUser() {
        DispatchQueue.main.async(execute: {
            _ = self.navigationController?.popViewController(animated: true)
        })
    }
    
    fileprivate func handleFailedAuthenticationWithError(_ error: NSError) {
        DispatchQueue.main.async(execute: {
            Crashlytics.sharedInstance().recordError(error)
            self.showErrorWithText("Something went wrong")
        })
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func errorButtonPressed(_ sender: UIButton) {
        hideErrorMsg()
    }
    func showErrorWithText(_ text:String) {
        errorMsgShowing = true
        errorMessageView.isUserInteractionEnabled = true
        errorLabel.text = text
        UIView.animate(withDuration: 0.2, animations: {
            self.errorMessageView.alpha = 1
        })
    }
    func hideErrorMsg() {
        errorMsgShowing = false
        errorMessageView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, animations: {
            self.errorMessageView.alpha = 0
        })
    }
}
