//
//  CropView.swift
//  Filterlapse
//
//  Created by Mathias on 2015-03-20.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class CropView: UIView {
    var croperViewFrame:CropViewFrame!
    var width:NSLayoutConstraint!
    var height:NSLayoutConstraint!
    var priorPoint:CGPoint = CGPoint.zero
    let reSizeCornerButtonSize:CGFloat = 60.0
    let inset:CGFloat = 35.0
    var reSizeTopLeft = false, reSizeTopRight = false, reSizeBottomLeft = false, reSizeBottomRight = false
    
    var holeRect:CGRect! {
        didSet{
            setNeedsDisplay()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let lpgr = UIPanGestureRecognizer(target: self, action: #selector(moveFrame(_:)))
        lpgr.minimumNumberOfTouches = 1
        self.addGestureRecognizer(lpgr)
        croperViewFrame = CropViewFrame(frame:CGRect(x: 100, y: 100, width: 100, height: 100))
        self.addSubview(croperViewFrame)
        holeRect = croperViewFrame.frame
    }
    override func draw(_ rect: CGRect) {
        UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).setFill()
        UIRectFill(rect)
        let holeRectIntersection = holeRect.intersection(rect)
        UIColor.clear.setFill()
        UIRectFill(holeRectIntersection)
    }
    func moveFrame(_ gestureRecognizer:UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        if gestureRecognizer.state == .began {
            let cornerSize = reSizeCornerButtonSize - inset
            let topLeft = CGRect(x: holeRect.origin.x - cornerSize, y: holeRect.origin.y - cornerSize, width: reSizeCornerButtonSize, height: reSizeCornerButtonSize)
            let topRight = CGRect(x: holeRect.origin.x + holeRect.size.width - inset, y: holeRect.origin.y - cornerSize, width: reSizeCornerButtonSize, height: reSizeCornerButtonSize)
            let bottomLeft = CGRect(x: holeRect.origin.x - cornerSize,y: holeRect.origin.y + holeRect.size.height - inset, width: reSizeCornerButtonSize, height: reSizeCornerButtonSize)
            let bottomRight = CGRect(x: holeRect.origin.x + holeRect.size.width - inset, y: holeRect.origin.y + holeRect.size.height - inset, width: reSizeCornerButtonSize, height: reSizeCornerButtonSize)
            reSizeTopLeft = topLeft.contains(point)
            reSizeTopRight = topRight.contains(point)
            reSizeBottomLeft = bottomLeft.contains(point)
            reSizeBottomRight = bottomRight.contains(point)
            priorPoint = point
        } else if gestureRecognizer.state == .changed {
            if reSizeTopLeft {
                reSizeView("topleft", point: point)
            } else if reSizeTopRight {
                reSizeView("topright", point: point)
            } else if reSizeBottomLeft {
                reSizeView("bottomleft", point: point)
            } else if reSizeBottomRight {
                reSizeView("bottomright", point: point)
            } else {
                moveView(point)
            }
        } else if gestureRecognizer.state == .ended {
            var cropFrame = croperViewFrame.frame
            if cropFrame.origin.y < 5.0 {
                cropFrame.origin.y = 0
            }
            if cropFrame.origin.x < 5.0 {
                cropFrame.origin.x = 0
            }
            if cropFrame.size.height + cropFrame.origin.y > self.frame.size.height - 5.0 {
                cropFrame.size.height = self.frame.size.height - cropFrame.origin.y
            }
            if cropFrame.size.width + cropFrame.origin.x > self.frame.size.width - 5.0 {
                cropFrame.size.width = self.frame.size.width - cropFrame.origin.x
            }
            UIView.animate(withDuration: 1.0, animations: {
                self.croperViewFrame.frame = cropFrame
            })
        }
        priorPoint = point
        holeRect = croperViewFrame.frame
    }
    func moveView(_ point:CGPoint) {
        var center = croperViewFrame.center
        let pointX = point.x - priorPoint.x
        let croperWidth = croperViewFrame.frame.size.width/2
        if (center.x - croperWidth > 0.0 || pointX > 0.0) && (center.x + croperWidth < frame.size.width || pointX < 0.0){
            let newCenterX = center.x + pointX
            if newCenterX - croperWidth < 0.0 {
                center.x = croperWidth
            } else if newCenterX + croperWidth > frame.size.width {
                center.x = frame.size.width - croperWidth
            } else {
                center.x += pointX
            }
        }
        let pointY = point.y - priorPoint.y
        let croperHeigth = croperViewFrame.frame.size.height/2
        if (center.y - croperHeigth > 0.0 || pointY > 0.0) && (center.y + croperHeigth < frame.size.height || pointY < 0.0){
            let newCenterY = center.y + pointY
            if newCenterY - croperHeigth < 0.0 {
                center.y = croperHeigth
            } else if newCenterY + croperHeigth > frame.size.height {
                center.y = frame.size.height - croperHeigth
            } else {
                center.y += pointY
            }
        }
        croperViewFrame.center = center
    }
    func reSizeView(_ direction:String, point:CGPoint) {
        let delta = point.x-priorPoint.x
        //let deltaHeight = point.y-priorPoint.y
        var frame = croperViewFrame.frame
        let top = frame.size.height < self.frame.size.height
        let led = frame.size.width + frame.origin.x < self.frame.size.width
        switch direction {
        case "topleft":
            if (led && top) || delta > 0 {
                frame.origin.y += delta
                frame.size.height -= delta
                frame.origin.x += delta
                frame.size.width -= delta
            }
        case "topright":
            print(delta)
            if (led && top) || delta < 0 {
                frame.size.width += delta
                frame.size.height += delta
                frame.origin.y -= delta
            }
        case "bottomleft":
            if (led && top) || delta > 0 {
                frame.size.height -= delta
                frame.size.width -= delta
                frame.origin.x += delta
            }
        case "bottomright":
            if (led && top) || delta < 0 {
                frame.size.width += delta
                frame.size.height += delta
            }
        default:
            break
        }
        if frame.origin.y < 1.0 {
            frame.origin.y = 0
        }
        if frame.origin.x < 1.0 {
            frame.origin.x = 0
        }
        if frame.size.height + frame.origin.y > self.frame.size.height - 1.0 {
            frame.size.height = self.frame.size.height - frame.origin.y
        }
        if frame.size.width + frame.origin.x > self.frame.size.width - 1.0 {
            frame.size.width = self.frame.size.width - frame.origin.x
        }
        croperViewFrame.frame = frame
    }
}
