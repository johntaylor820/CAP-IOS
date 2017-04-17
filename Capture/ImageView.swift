//
//  ImageView.swift
//  Capture
//
//  Created by Mathias Palm on 2016-06-09.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import Haneke

class ImageView: UIImageView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        layer.masksToBounds = true
        contentMode = .scaleAspectFill
    }
    func prepareForReuse() {
        hnk_cancelSetImage()
        image = nil
    }
    
    // MARK: - Activity indicator
    func loadImage(_ urlString: String) {
        if let url = URL(string: urlString) {
            hnk_setImageFromURL(url)
        }
    }
}

class ShadowImage: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 16)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 7.5
        clipsToBounds = false
    }
}
