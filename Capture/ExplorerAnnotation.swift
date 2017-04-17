//
//  ExplorerAnnotation.swift
//  Capture
//
//  Created by Mathias Palm on 2016-09-12.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import MapKit

private let kAPIKeyLikes = "likes"
private let kAPIKeyLong = "long"
private let kAPIKeyLat = "lat"
private let kAPIKeyId = "id"

class ExplorerAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var id: Int = 0
    var likes: Int = 0
    var title: String? = ""
    var subtitle: String? = ""
    
    init(dictionary: [String : AnyObject]) {
        var long:Double = 0.0
        var lat:Double = 0.0
        if let newLong = dictionary[kAPIKeyLong] as? Double {
            long = newLong
        }
        if let newLat = dictionary[kAPIKeyLat] as? Double {
            lat = newLat
        }
        coordinate = CLLocationCoordinate2DMake(lat, long)
        if let newId = dictionary[kAPIKeyId] as? Int {
            id = newId
        }
        if let newLikes = dictionary[kAPIKeyLikes] as? Int {
            likes = newLikes
        }
    }
    func annotationView() -> MKAnnotationView {
        let view = MKAnnotationView(annotation: self, reuseIdentifier: "CustomAnnotation")

        view.canShowCallout = false
        view.image = UIImage(named: "location-explorer")
        var frame = view.frame
        view.centerOffset = CGPoint(x: 0, y: -(frame.size.height*0.3))
        
        frame.size.height *= 0.8
        frame.size.width *= 0.8
        view.frame = frame
        
        let bubble = SpeachBubble(numLikes: likes)
        bubble.center = CGPoint(x: bubble.center.x+1, y: bubble.center.y-bubble.frame.size.height+5)
        view.addSubview(bubble)

        return view
    }
}
