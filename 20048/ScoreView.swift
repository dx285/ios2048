//
//  TileView.swift
//  20048
//
//  Created by Di on 8/18/15.
//  Copyright (c) 2015 Di. All rights reserved.
//

import UIKit

protocol scoreUpdateProtocol{
    func scoreUpdated(newScore s: Int)
}

class ScoreView: UIView, scoreUpdateProtocol {
    
    var scoreLabel: UILabel
    
    var score:Int = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let defaultFrame = CGRectMake(0, 0, 140, 40)
    
    init(backgroundColor bgColor: UIColor, textColor tColor: UIColor, font: UIFont, radius r: CGFloat){
        scoreLabel = UILabel(frame: defaultFrame)
        scoreLabel.textAlignment = NSTextAlignment.Center
        scoreLabel.textColor = tColor
        scoreLabel.font = font
        
        super.init(frame: defaultFrame)
        
        backgroundColor = bgColor
        layer.cornerRadius = r
        self.addSubview(scoreLabel)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    //implement 
    func scoreUpdated(newScore s: Int) {
        score = s
    }
}


//undecided 
class ControlView{

}
