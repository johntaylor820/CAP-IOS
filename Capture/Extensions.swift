//
//  Extensions.swift
//  Capture
//
//  Created by Mathias Palm on 2016-03-26.
//  Copyright © 2016 capture. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import GPUImage
import Haneke

extension UIImageView {
    func makeBlurImage() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibracneView = UIVisualEffectView(effect: vibrancyEffect)
        vibracneView.frame = bounds
        vibracneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(vibracneView)
    }
}
extension UIView {
    func makeBlur(_ targetImageView:UIView?) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = targetImageView!.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        targetImageView?.addSubview(blurEffectView)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibracneView = UIVisualEffectView(effect: vibrancyEffect)
        vibracneView.frame = targetImageView!.bounds
        vibracneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        targetImageView?.addSubview(vibracneView)
    }
}

extension UIImage {
    func resizeImage(_ newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension String {
    func isValidWithRegEx(_ string:String, regEx:String) -> Bool {
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        let result = test.evaluate(with: string)
        return result
    }
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}



extension UITextView {
    
    func editedWord() -> String? {
        var cursorPosition = selectedRange.location
        let separationCharacters = CharacterSet(charactersIn: " ")
        if cursorPosition > text.characters.count {
            cursorPosition = text.characters.count
        }
        let beginRange = text.index(text.startIndex, offsetBy: 0)..<text.index(text.startIndex, offsetBy: cursorPosition)
        let endRange = text.index(text.startIndex, offsetBy: cursorPosition)..<text.index(text.startIndex, offsetBy: text.characters.count)
        let beginPhrase = text.substring(with: beginRange)
        let endPhrase = text.substring(with: endRange)
        let beginWords = beginPhrase.components(separatedBy: separationCharacters)
        let endWords = endPhrase.components(separatedBy: separationCharacters)
        return beginWords.last! + endWords.first!
    }
}

extension Date {
    func getElapsedInterval() -> String {
        var calender =  Calendar.current
        calender.timeZone =  TimeZone(identifier: "UTC")!
        var interval = (calender as NSCalendar).components(.year, from: self, to: Date(), options: []).year
        if interval! > 0 {
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        interval = (Calendar.current as NSCalendar).components(.month, from: self, to: Date(), options: []).month
        if interval! > 0 {
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        interval = (Calendar.current as NSCalendar).components(.day, from: self, to: Date(), options: []).day
        if interval! > 0 {
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        interval = (Calendar.current as NSCalendar).components(.hour, from: self, to: Date(), options: []).hour
        if interval! > 0 {
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        interval = (Calendar.current as NSCalendar).components(.minute, from: self, to: Date(), options: []).minute
        if interval! > 0 {
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        return "a moment ago"
    }
}
