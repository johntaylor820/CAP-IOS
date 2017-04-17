//
//  RegisterViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-03-24.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Crashlytics

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userImageBackgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var addBackgroundButton: UIButton!
    @IBOutlet weak var backgroundLabel: UILabel!
    
    @IBOutlet weak var errorBackgroundView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    var activeTag = 0
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var clearEmailView: UIView!
    @IBOutlet weak var clearUsernameView: UIView!
    
    let imagePicker = UIImagePickerController()
    
    var usernameEntered = false
    var passwordEntered = false
    let screenHeight = UIScreen.main.bounds.height
    
    var changeBG = false
    
    var errorMsgShowing = false
    @IBOutlet weak var chopperHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(email)
        print(fullName)
        
        chopperHeight.constant = 1/UIScreen.main.scale
        view.layoutIfNeeded()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        errorBackgroundView.layer.cornerRadius = 5
        imagePicker.sourceType = .photoLibrary
        
        if FBlogin == true{
            
            self.emailTextField.text = email
            self.usernameTextField.text = first_name
            self.userImageView.image = profileImage
            self.nameTextField.text = fullName

        } else if TWIlogin == true {
            
            self.emailTextField.text = email
            self.usernameTextField.text = first_name
            self.userImageView.image = profileImage
            self.nameTextField.text = fullName
            self.backgroundImageView.image = backImage
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.tap(_:)))
        infoView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageBackgroundView.layer.cornerRadius = userImageBackgroundView.frame.size.width/2
        userImageView.layer.cornerRadius = userImageView.frame.size.width/2
    }
    
    func setUserPictures() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take a Photo", style: .default) { action -> Void in
            
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }
        actionSheetController.addAction(takePictureAction)
        
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose a Photo", style: .default) { action -> Void in
            
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }
        actionSheetController.addAction(choosePictureAction)
        self.present(actionSheetController, animated: true, completion: nil)

    }
    
    @IBAction func addUserImage(_ sender: UIButton) {
        setUserPictures()
    }
    
    @IBAction func addBackgroundPressed(_ sender: UIButton) {
        changeBG = true
        setUserPictures()
    }
    
    @IBAction func textFieldIsActive(_ sender: UITextField) {
        activeTag = sender.tag
    }
    
    @IBAction func checkEmail(_ sender: UITextField) {
        if sender.text != "" {
            let check = sender.text!.isValidWithRegEx(sender.text!, regEx:"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,4}")
            if check {
                checkEmail(sender.text!, completion: {
                    (success:Bool) in
                    if success {
                        DispatchQueue.main.async(execute: {
                            self.clearEmailView.alpha = 0
                            self.clearEmailView.isUserInteractionEnabled = false
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            self.clearEmailView.alpha = 1
                            self.clearEmailView.isUserInteractionEnabled = true
                        })
                    }
                })
            } else {
                self.showErrorWithText("Email Is Unvalid!")
            }
        }
    }
    func clearEmailFields() {
        emailTextField.text = ""
        clearEmailView.alpha = 0
        clearEmailView.isUserInteractionEnabled = false
    }
    @IBAction func clearEmail(_ sender: UIButton) {
        clearEmailFields()
    }
    
    @IBAction func checkUsername(_ sender: UITextField) {
        if sender.text != "" {
            let check = sender.text!.isValidWithRegEx(sender.text!, regEx:"[A-Z0-9a-z_-]{1,40}")
            if check {
                checkUser(sender.text!, completion: {
                    (success:Bool) in
                    DispatchQueue.main.async(execute: {
                        if success {
                            self.usernameEntered = true
                            self.clearUsernameView.alpha = 0
                            self.clearUsernameView.isUserInteractionEnabled = false
                        } else {
                            self.usernameEntered = false
                            self.clearUsernameView.alpha = 1
                            self.clearUsernameView.isUserInteractionEnabled = true
                        }
                        self.showNextButton()
                    })
                })
            } else {
                self.showErrorWithText("User name can only contain a-z, 0-9 and some special signs")
            }
        }
    }
    @IBAction func clearUser(_ sender: UIButton) {
        usernameTextField.text = ""
        clearUsernameView.alpha = 0
        clearUsernameView.isUserInteractionEnabled = false
    }
    @IBAction func passwordChanged(_ sender: UITextField) {
        if sender.text! != "" {
            passwordEntered = true
            
        } else {
            passwordEntered = false
        }
        showNextButton()
    }
    @IBAction func usernameChanged(_ sender: UITextField) {
        if sender.text! != "" {
            usernameEntered = true
            
        } else {
            usernameEntered = false
        }
        showNextButton()
    }
    
    @IBAction func checkPassword(_ sender: UITextField) {
        if sender.text != "" {
            let whitespace = CharacterSet.whitespaces
            let range = sender.text!.rangeOfCharacter(from: whitespace)
            if range == nil {
                passwordEntered = true
            } else {
                self.showErrorWithText("password can not contain any spaces")
                passwordTextField.text = ""
                passwordEntered = false
            }
            showNextButton()
        }
    }
    
    func showNextButton() {
        if usernameEntered && passwordEntered {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func changeBackground(_ image:UIImage) {
        backgroundImageView.contentMode = .scaleAspectFill
        let newImage = image.resizeImage(view.frame.size.width*2)
        backgroundImageView.image = newImage
        //backgroundImageView.makeBlurImage(backgroundImageView)
        changeBG = false
        backgroundLabel.text = "Change Background"
        //addBackgroundButton.setTitle("Change Background", forState: .Normal)
    }
    func changeUserImage(_ image:UIImage) {
        userImageView.contentMode = .scaleAspectFill
        let newImage = image.resizeImage(200)
        userImageView.image = newImage
    }
    
    func showErrorWithText(_ text:String) {
        errorMsgShowing = true
        errorBackgroundView.isUserInteractionEnabled = true
        errorLabel.text = text
        UIView.animate(withDuration: 0.2, animations: {
            self.errorBackgroundView.alpha = 1
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
        errorBackgroundView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, animations: {
            self.errorBackgroundView.alpha = 0
        })
    }
    @IBAction func hideErrorClicked(_ sender: UIButton) {
        hideErrorMsg()
    }
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        var param = [
            "username"  : usernameTextField.text!,
            "password" : passwordTextField.text!,
        ]
        if let name = nameTextField.text {
            param["fullname"] = name
        }
        if let email = emailTextField.text {
            param["email"] = email
        }
        if let location = locationTextField.text {
            param["location"] = location
        }
        signUp(param, completion: { (id: Int, success:Bool) in
            if success {
                DispatchQueue.main.async(execute: {
                    self.setprofilePic(id)
                    self.setBgPic(id)
                    self.performSegue(withIdentifier: "tosView", sender: nil)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.showErrorWithText("Something went wrong")
                })
            }
        })
    }
    func setprofilePic(_ id: Int) {
        if let profilepic = userImageView.image {
            UserManager.sharedInstance.updateProfilePictureForUser(id, profilePicture: profilepic, completion: {(succes, error) in
            })
        }
    }
    func setBgPic(_ id: Int) {
        if let background = backgroundImageView.image {
            let newImage = background.resizeImage(view.frame.size.width*2)
            UserManager.sharedInstance.updateBackgroundPhotoForUser(id, backgroundPhoto: newImage, completion: {(succes, error) in
            })
        }
    }
    //MARK: - Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if changeBG {
            
            self.performSegue(withIdentifier: "toCrop", sender: nil)
            changeBackground(image)
        } else {
            changeUserImage(image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Gesture Delegates
    func tap(_ gesture: UITapGestureRecognizer) {
        if errorMsgShowing {
            hideErrorMsg()
        }
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 5 {
            textField.resignFirstResponder()
            showNextButton()
        } else {
            let nextTag: Int = textField.tag + 1
            if let nextResponder: UIResponder? = textField.superview!.viewWithTag (nextTag) {
                nextResponder?.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
    }
    func keyboardWillShow(_ notification: Notification) {
            var height:CGFloat = 0
            if let actView = view.viewWithTag(activeTag) {
                if activeTag > 2 {
                    let actY = view.convert(view.frame, from: actView).origin.y
                        height = (screenHeight/2 - actY) + topSpaceConstraint.constant
                }
            }
            topSpaceConstraint.constant = height
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        topSpaceConstraint.constant = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
extension RegisterViewController {
    func signUp(_ param:[String: String], completion: @escaping (_ id: Int, _ success: Bool) -> Void) {
        UserManager.sharedInstance.registerUser(param, completion: {id, success, error in
            
//            guard success && error == nil else {
//                Crashlytics.sharedInstance().recordError((error)!)
//                return
//            }
            
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
            
            DispatchQueue.main.async(execute: {
                completion(id, success)
            })
        })
    }
    func checkUser(_ username: String, completion: @escaping (_ success:Bool) -> Void) {
        UserManager.sharedInstance.checkUsername(username, completion: {success, error in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
            DispatchQueue.main.async(execute: {
                completion(success)
            })
        })
    }
    func checkEmail(_ email: String, completion: @escaping (_ success:Bool) -> Void) {
        UserManager.sharedInstance.checkEmail(email, completion: {success, error in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
            DispatchQueue.main.async(execute: {
                completion(success)
            })
        })
    }
}



