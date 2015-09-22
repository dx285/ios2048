//
//  TileView.swift
//  20048
//
//  Created by Di on 8/18/15.
//  Copyright (c) 2015 Di. All rights reserved.
//

import UIKit

class TileView: UIView {
    
    var numberLabel: UILabel
    var delegate: DecoratorProtocol
    
    var value: Int = 0{
        didSet{
            backgroundColor = delegate.tileColor(value)
            numberLabel.textColor = delegate.numColor(value)
            numberLabel.text = "\(value)"
        }
    }
    
    init(position: CGPoint, width: CGFloat, value: Int, radius: CGFloat, delegate d: DecoratorProtocol){
        
        delegate = d
        
        //Must call a designated initializer of the superclass 'UIView'
        numberLabel = UILabel(frame: CGRectMake(0, 0, width, width))
        numberLabel.textAlignment = NSTextAlignment.Center
        numberLabel.minimumScaleFactor = 0.5
        numberLabel.font = delegate.fontForNum()
        numberLabel.textColor = delegate.numColor(value)
        numberLabel.text = "\(value)"
        
        self.value = value
        super.init(frame:CGRectMake(position.x, position.y, width, width))
        
        //Use of 'self' in property access 'layer' before super.init initializes self
        backgroundColor = delegate.tileColor(value)
        layer.cornerRadius = radius
        addSubview(numberLabel)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
