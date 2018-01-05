//
//  MyUIButton.swift
//  Bejeweled
//
//  Created by Daniel Defta on 23/12/2017.
//  Copyright © 2017 Daniel Defta. All rights reserved.
//

import UIKit

@IBDesignable class MyUIButton: UIButton {
    @IBInspectable var bgColor: UIColor = UIColor.clear
    @IBInspectable var cornerRadius : CGFloat = 5
    @IBInspectable var borderWidth : CGFloat = 2
    @IBInspectable var borderColor : UIColor = UIColor.blue
    @IBInspectable var scaleContent : CGFloat = 1.5
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.backgroundColor = bgColor.cgColor
        frame.size.width = rect.size.width * scaleContent
        frame.size.height = rect.size.height * scaleContent
        

    }

}
