//
//  InstagramActivity.swift
//  Filterlapse
//
//  Created by Mathias on 2014-12-02.
//  Copyright (c) 2014 Mathias Palm. All rights reserved.
//

import UIKit

class InstagramActivity: UIActivity {
    var assetURLFromLibrary:URL!
    var message:String!
    
    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "Instagram.Share.App")
    }
    
    override var activityTitle : String? {
        return "Instagram"
    }
    override class var activityCategory : UIActivityCategory {
        return .share
    }
    override var activityImage : UIImage? {
        return UIImage(named: "instagram_ios8")
    }
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    override func prepare(withActivityItems activityItems: [Any]) {
        assetURLFromLibrary = activityItems[0] as! URL
        message = activityItems[1] as! String
    }
    override var activityViewController : UIViewController? {
        return nil
    }
    override func perform() {
        let escapeString:String!  = assetURLFromLibrary.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        let escapedCaption:String! = message.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        let instagramURL:URL! = URL(string:"instagram://library?AssetPath=\(escapeString)&InstagramCaption=\(escapedCaption)")
        if UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.openURL(instagramURL)
        }
        activityDidFinish(true)
    }
    
}
