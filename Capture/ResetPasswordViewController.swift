//
//  ResetPasswordViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-07-09.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorMasseageView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var sendEmailButton: ResetPasswordButton!
    
    @IBOutlet weak var chopperHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        chopperHeight.constant = 1/UIScreen.main.scale
        view.layoutIfNeeded()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resetEmail()
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
    }
    @IBAction func sendEmail(_ sender: AnyObject) {
        resetEmail()
    }
    
    func resetEmail() {
        if emailTextField.isFirstResponder {
           emailTextField.resignFirstResponder()
        }
        sendEmailButton.startLoading()
        if let email = emailTextField.text {
            UserManager.sharedInstance.restoreUserPassword(email, completion: { success, error in
                guard success && error == nil else {
                    debugPrint(error!)
                    self.showErrorWithText("Email does not exists or an error accured")
                    return
                }
                self.showErrorWithText("Password successfully sent!")
            })
        }
    }
    func showErrorWithText(_ text:String) {
        sendEmailButton.stopLoading()
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
    
    @IBAction func closeError(_ sender: AnyObject) {
        hideErrorMsg()
    }
    func hideErrorMsg() {
        errorMasseageView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, animations: {
            self.errorMasseageView.alpha = 0
        })
    }
    @IBAction func back(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
}
