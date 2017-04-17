//
//  WelcomeViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-03-23.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import GPUImage
import FBSDKLoginKit
import TwitterKit

var fullName = ""
var profileImage = UIImage()
var email = ""
var first_name = ""
var FBlogin = false
var TWIlogin = false
var backImage = UIImage()


class WelcomeViewController: UIViewController, UINavigationControllerDelegate {
    var login = ""
    var twiData = [String: AnyObject]()


    var username : String {
        get {
            var returnValue : String? = UserDefaults.standard.object(forKey: "capture_user") as? String
            if returnValue == nil
            {
                returnValue = ""
            }
            return returnValue!
        }
    }
    var password : String {
        get {
            var returnValue : String? = UserDefaults.standard.object(forKey: "capture_pw") as? String
            if returnValue == nil
            {
                returnValue = ""
            }
            return returnValue!
        }
    }
    override func viewDidLoad() {
        navigationController?.navigationBar.isHidden = true
        super.viewDidLoad()
        TWIlogin = false
        FBlogin = false
        if username != "" && password != "" {
            login = "direct"
            performSegue(withIdentifier: "login", sender: self)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    override var prefersStatusBarHidden : Bool {
//        return false
//    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            login = "facebook"
        case 1:
            login = "twitter"
        case 2:
            login = "normal"
        default:
            break
        }
        performSegue(withIdentifier: "login", sender: self)
    }
    
    @IBAction func signupWithTwitter(_ sender: Button) {
        
        TWIlogin = true
        
        Twitter.sharedInstance().logIn(withMethods: [.webBased]) { (session, error) in
            
            if (session != nil) {
                
                print(session as Any)
                print("signed in as \(session!.userName)");
                
                
                let client = TWTRAPIClient.withCurrentUser()
                
                let request = client.urlRequest(withMethod: "GET", url: "https://api.twitter.com/1.1/account/verify_credentials.json", parameters: ["include_entities": "false", "include_email": "true", "skip_status": "true"], error: nil)
                
                client.sendTwitterRequest(request) { response, data, connectionError in
                    
                    print(response as Any)
                    print(data as Any)
                    
                    if connectionError != nil {
                        print("Error: \(connectionError)")
                        
                    }else{
                        do {
                            let twitterJson = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
                            print("json: \(twitterJson)")
                            
//                            let profile_image_url = twitterJson["profile_image_url"]
//                            let profile_banner_url = twitterJson["profile_banner_url"]

//                            self.twiData.updateValue(twitterJson["email"]!, forKey: "email")
                            self.twiData.updateValue(twitterJson["name"]!, forKey: "name")
                            self.twiData.updateValue(twitterJson["profile_image_url"]!, forKey: "image")
                            self.twiData.updateValue(twitterJson["profile_banner_url"]!, forKey: "backImage")
                            
                            let name = twitterJson["name"]
//                            email = twitterJson["email"] as! String
                            first_name = session!.userName
                            fullName = name as! String
                            
                            //profile image
                            let profileImageUrl = twitterJson["profile_image_url"]
                            let pictureURL = NSURL(string: profileImageUrl as! String)
                            let imageData = NSData(contentsOf: pictureURL! as URL)
                            let image = UIImage(data: imageData! as Data)
                            profileImage = image!
                            
                            //background image
                            let bannerImageString = twitterJson["profile_banner_url"]
                            let bannerImageUrl = NSURL(string: bannerImageString as! String)
                            let bannerimageData = NSData(contentsOf: bannerImageUrl! as URL)
                            let bannerImage = UIImage(data: bannerimageData! as Data)
                            backImage = bannerImage!
                            
                            print(self.twiData)
                            
                        } catch let jsonError as NSError {
                            print("json error: \(jsonError.localizedDescription)")
                            
                        }
                    }
                    
                }
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                self.navigationController?.pushViewController(vc, animated: true )

            } else {
                print("error: \(error!.localizedDescription)");
            }
            
            
        }

    }
    @IBAction func signupWithFacebook(_ sender: Button) {
        
        FBlogin = true
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                    
                }

            }
        }

    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil && result != nil){
                    //everything works print the user data
                    let info = result as! NSDictionary

                    if let id: NSString = info.value(forKey: "name") as! NSString?{
                        fullName = id as String
                        
                        print(id)
                    }
                    if let id: NSString = info.value(forKey: "first_name") as! NSString?{
                        first_name = id as String
                        print(id)
                    }
                    
                    if let id: NSString = info.value(forKey: "email") as! NSString?{
                        email = id as String
                        print(id)
                    }
                    
                    if let imageURL = ((info.value(forKey: "picture") as AnyObject).value(forKey: "data") as AnyObject).value(forKey: "url") as? String {
                        
                        print(imageURL)
                        let pictureURL = NSURL(string: imageURL)
                        let imageData = NSData(contentsOf: pictureURL! as URL)
                        let image = UIImage(data: imageData! as Data)
                        profileImage = image!
                        
                        //Download image from imageURL
                    }
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                    self.navigationController?.pushViewController(vc, animated: true )

                    print(result)
                }
                
            })
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let item = UIBarButtonItem()
        item.title = "Cancel"
        navigationItem.backBarButtonItem = item
        if segue.identifier == "login" {
            let vc: LoginViewController = segue.destination as! LoginViewController
            vc.loginState = self.login
        }
    }
    

}
