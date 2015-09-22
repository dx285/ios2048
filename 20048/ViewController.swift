//
//  ViewController.swift
//  20048
//
//  Created by Di on 8/18/15.
//  Copyright (c) 2015 Di. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let dimension = 4
    let threshold = 2048

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func startGame(sender: UIButton) {
        
        let game = GameController(dimension: dimension, threshold: threshold)
        self.presentViewController(game,
            animated: true,
            completion: nil)
    }


}

