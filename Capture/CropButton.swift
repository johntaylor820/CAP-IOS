//
//  CropButton.swift
//  Filterlapse
//
//  Created by Mathias on 2015-03-19.
//  Copyright (c) 2015 Mathias Palm. All rights reserved.
//

import UIKit

class CropButton: UIButton {
    override var isSelected:Bool {
        didSet{
            setSelected()
        }
    }
    init(frame: CGRect, image:Int) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0).cgColor
    }
    
    func setSelected() {
        if isSelected == true {
            self.layer.borderColor = UIColor(red: 85/255.0, green: 110/255.0, blue: 238/255.0, alpha: 1.0).cgColor
        } else {
            self.layer.borderColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0).cgColor
        }
    }
}
