//
//  MyUIProgressView.swift
//  Bejeweled
//
//  Created by Daniel Defta on 26/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import UIKit

@IBDesignable class MyUIProgressView: UIProgressView {

    @IBInspectable var cornerRadius : CGFloat = 0
    @IBInspectable var height : CGFloat = 10
    @IBInspectable var pgColor: UIColor? = UIColor.clear
    @IBInspectable var trackColor : UIColor? = UIColor.blue


    
    override func draw(_ rect: CGRect) {
        layer.bounds.size.height = height
        progressTintColor = pgColor
        trackTintColor = trackColor
    }
    
}

