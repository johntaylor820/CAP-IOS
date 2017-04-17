//
//  EditMeViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-04-23.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics

protocol EditMeViewControllerDelegate {
    func refreshInfo(_ profilePic:Bool, bg:Bool)
}

class EditMeViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var userImageBackgroundView: BackgroundImageView!
    @IBOutlet weak var userImageView: CircularImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emilTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var bioTextView: BioTextView!
    
    @IBOutlet weak var editScrollView: UIScrollView!
    
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var bgImageButton: UIButton!
    var activeTag = 0

    var newUserImage = false
    var newBgImage = false
    var delegate:EditMeViewControllerDelegate?
    
    var user: User!

    var changeBG = false
    let imagePicker = UIImagePickerController()
    
    @IBOutlet var chopperHeights: [NSLayoutConstraint]!

    override func viewDidLoad() {
        super.viewDidLoad()
        for chopperHeight in chopperHeights {
            chopperHeight.constant = 1/UIScreen.main.scale
        }
        bioTextView.text = bioTextView.placeholderText
        bioTextView.textColor = bioTextView.placeholderColor
        bioTextView.selectedTextRange = bioTextView.textRange(from: bioTextView.beginningOfDocument, to: bioTextView.beginningOfDocument)
        view.layoutIfNeeded()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        bioTextView.contentInset = UIEdgeInsetsMake(0,-4,0,0)
        setUser()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditMeViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(EditMeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        resignActives()
        if newUserImage {setprofilePic()}
        if newBgImage {setBgPic()}
        updateUserInfo()
        self.dismiss(animated: true, completion: nil)
    }

    func setUser() {
        userImageBackgroundView.setImageForUser(user)
        userImageView.setImageForUser(user)
        nameTextField.text = user.fullName
        usernameTextField.text = "@"+user.username
        emilTextField.text = user.email
        websiteTextField.text = user.website
        if user.info.characters.count > 0 {
            bioTextView.text = user.info
            bioTextView.textColor = bioTextView.nonPlaceholderColor
        }
        locationTextField.text = user.location
    }

    
    func setprofilePic() {
        if let profilepic = userImageView.image {
            UserManager.sharedInstance.updateProfilePictureForUser(user.id, profilePicture: profilepic, completion:{(succes, error) in
                guard succes && error == nil else {
                    return
                }
                DispatchQueue.main.async(execute: {
                    self.user = UserManager.sharedInstance.user
                    self.userImageView.setImageForUser(self.user)
                    self.delegate?.refreshInfo(true, bg:false)
                })
            })
        }
    }
    func setBgPic() {
        if let background = userImageBackgroundView.image {
            let newImage = background.resizeImage(view.frame.size.width*2)
            UserManager.sharedInstance.updateBackgroundPhotoForUser(user.id, backgroundPhoto: newImage, completion: {(succes, error) in
                guard succes && error == nil else {
                    return
                }
                DispatchQueue.main.async(execute: {
                    self.user = UserManager.sharedInstance.user
                    self.userImageView.setImageForUser(self.user)
                    self.delegate?.refreshInfo(false, bg:true)
                })
            })
        }
    }

    func updateUserInfo() {
        if let name = nameTextField.text {
            user.fullName = name
        }
        if let username = usernameTextField.text {
            if username.characters.count > 1 {
                let noAtName = username.substring(from: username.characters.index(username.startIndex, offsetBy: 1))
                user.username = noAtName
            }
        }
        if let email = emilTextField.text {
            user.email = email
        }
        if let website = websiteTextField.text {
            user.website = website
        }
        if let location = locationTextField.text {
            user.location = location
        }
        if bioTextView.text != bioTextView.placeholderText {
            var bio = bioTextView.text
            if (bio?.characters.count)! > 160 {
                bio = bio?.substring(to: (bio?.index((bio?.startIndex)!, offsetBy: 160))!)
            }
            user.info = bio!
        }
        UserManager.sharedInstance.updateUser(user, completion: { (user, error) in
            guard user != nil && error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                return
            }
            DispatchQueue.main.async(execute: {
                self.user = user
                self.delegate?.refreshInfo(false, bg:false)
            })
        })
    }

    @IBAction func editUserImagePressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func editBgImagePressed(_ sender: UIButton) {
        changeBG = true
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func shareSettingsPressed(_ sender: UITapGestureRecognizer) {
        
    }
    
    @IBAction func changePasswordPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "changePassword", sender: nil)
    }
    @IBAction func textIsEditing(_ sender: AnyObject) {
        activeTag = sender.tag
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        }
        let okAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            UserManager.sharedInstance.logoutUserWithCompletion {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.navigateToLogin(true)
                }
            }
        }
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func changeBackground(_ image:UIImage) {
        newBgImage = true
        userImageBackgroundView.setBgImg(image)
        changeBG = false
    }
    func changeUserImage(_ image:UIImage) {
        newUserImage = true
        userImageView.contentMode = .scaleAspectFill
        userImageView.image = image
    }
    
    //MARK: - Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if changeBG {
            changeBackground(image)
        } else {
            changeUserImage(image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Gesture Delegates
    func tap(_ gesture: UITapGestureRecognizer) {
        resignActives()
    }
    func resignActives() {
        nameTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        emilTextField.resignFirstResponder()
        websiteTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        bioTextView.resignFirstResponder()
    }
    
    //MARK: - TextField Delegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        if updatedText.isEmpty {
            
            textView.text = bioTextView.placeholderText
            textView.textColor = bioTextView.placeholderColor
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        } else if textView.textColor == bioTextView.placeholderColor && !text.isEmpty {
            textView.text = nil
            textView.textColor = bioTextView.nonPlaceholderColor
        }
        
        return true
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeTag = textView.tag
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == bioTextView.placeholderColor {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1
        if let nextResponder: UIResponder? = view.viewWithTag(nextTag) {
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func keyboardWillShow(_ notification: Notification) {
        var rect = CGRect(x: 0, y: 0, width: editScrollView.frame.size.width, height: editScrollView.frame.size.height)
        rect.origin.y = (CGFloat(activeTag) - 1) * 50
        editScrollView.scrollRectToVisible(rect, animated: true)
    }
}

