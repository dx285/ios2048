//
//  GameController.swift
//  20048
//
//  Created by Di on 8/18/15.
//  Copyright (c) 2015 Di. All rights reserved.
//

import UIKit

class GameController: UIViewController, GameModelProtocol {
    
    var dimension: Int
    var threshold: Int
    
    let boardWidth: CGFloat = 230.0
    let thinPadding: CGFloat = 3.0
    let thickPadding: CGFloat = 6.0
    let viewPadding: CGFloat = 10.0
    //let spacePadding: CGFloat = 10.0
    let verticalViewOffset: CGFloat = 0.0
    
    var model: GameModel?
    var board: GameBoardView?
    var scoreView: scoreUpdateProtocol?
    
    init(dimension d:Int, threshold t: Int){
        dimension = d > 2 ? d : 2
        threshold = t > 8 ? t : 8
        super.init(nibName: nil, bundle: nil)
        
        //implement delegates methods first
        model = GameModel(dimension: dimension, threshold: threshold, delegate: self)
        view.backgroundColor = UIColor.whiteColor()
        setupSwipeControl()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSwipeControl(){
        let upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("up:"))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("down:"))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("left:"))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("right:"))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupGame(){
        
        let vHeight = view.bounds.size.height
        let vWidth = view.bounds.size.width
        
        func xPosInParentView(v: UIView) -> CGFloat{
            let viewWidth = v.bounds.size.width
            let tentativeX = 0.5*(vWidth - viewWidth)
            
            //test
            println("x pos: \(tentativeX)")
            
            return tentativeX >= 0 ? tentativeX : 0
        }
        
        func yPosInParentView(order: Int, views: [UIView]) -> CGFloat{
            assert(views.count>0)
            assert(order>=0 && order<views.count)
            
            let totalHeight = CGFloat(views.count-1)*viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, combine: { $0 + $1 })
            
            let viewTop = 0.5*(vHeight - totalHeight) >= 0 ? 0.5*(vHeight - totalHeight) : 0
            var acc: CGFloat = 0
            
            for i in 0..<order{
                acc += viewPadding + views[i].bounds.size.height
            }
            
            //test
            println("y pos: \(viewTop+acc)")

            
            return viewTop + acc
        }
        
        //init scoreView
        let scoreView = ScoreView(backgroundColor: UIColor.blackColor(),
            textColor: UIColor.whiteColor(),
            font: UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFontOfSize(16.0),
            radius: 6)
        scoreView.score = 0
        
        
        //test
        println("original scoreView x: \(scoreView.bounds.size.width)")
        println("original scoreView y: \(scoreView.bounds.size.height)")
        
        
        let padding = dimension > 5 ? thinPadding : thickPadding
        let v1 = boardWidth - padding*(CGFloat(dimension+1))
        //let tileWidth = CGFloat(floorf(CGFloat(v1)))/CGFloat(dimension)
        let tileWidth = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
        
        //test
        println("tile width: \(tileWidth)")
        
        let gameboard = GameBoardView(dimension: dimension,
            tileWidth: tileWidth,
            tilePadding: padding,
            cornerRadius: 6,
            backgroundColor: UIColor.blackColor(),
            foregroundColor: UIColor.darkGrayColor()
        )
        
        //test
        println("original gameboard x: \(gameboard.bounds.size.width)")
        println("original gameboard y: \(gameboard.bounds.size.height)")
        
        let views = [scoreView, gameboard]
        var f = scoreView.frame
        
        f.origin.x = xPosInParentView(scoreView)
        f.origin.y = yPosInParentView(0, views)
        scoreView.frame = f
        
        //test
        println("after scoreView x: \(scoreView.bounds.size.width)")
        println("after scoreView y: \(scoreView.bounds.size.height)")
        
        f = gameboard.frame
        f.origin.x = xPosInParentView(gameboard)
        f.origin.y = yPosInParentView(1, views)
        gameboard.frame = f
        
        
        //test
        println("after gameboard x: \(gameboard.bounds.size.width)")
        println("after gameboard y: \(gameboard.bounds.size.height)")
        
        board = gameboard
        self.scoreView = scoreView
        view.addSubview(gameboard)
        view.addSubview(scoreView)
        
        assert(model != nil)
        let m = model!
        m.insertTileAtRandomLocation(2)
        m.insertTileAtRandomLocation(2)
        
    }
    
    
    //MARK: Protocol implements
    func scoreChanged(score: Int){
        if scoreView == nil {
            return
        }
        
        scoreView!.scoreUpdated(newScore: score)
    }
    
    
    func moveOneTile(from: (Int, Int), to: (Int,Int), value: Int){
        assert(board != nil)
        
        board!.moveOneTile(from, to: to, value: value)
    }
    
    
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int){
        assert(board != nil)
        board!.moveTwoTiles(from, to: to, value: value)
    }
    
    
    func insertTile(location: (Int, Int), value: Int){
        assert(board != nil)
        board!.insertTile(location, value: value)
    }
    
    
    //Gesture commands
    
    @objc(up:)
    func upCommand(r:UIGestureRecognizer){
        assert(model != nil)
        let m = model!
        m.queueMove(MoveDirection.Up
            , completion: { (changed: Bool) -> () in
                if changed {
                    self.followUp()
                }
        })
    }
    
    @objc(left:)
    func leftCommand(r:UIGestureRecognizer){
        assert(model != nil)
        let m = model!
        m.queueMove(MoveDirection.Left
            , completion: { (changed: Bool) -> () in
                if changed {
                    self.followUp()
                }
        })
    }
    
    @objc(right:)
    func rightCommand(r:UIGestureRecognizer){
        assert(model != nil)
        let m = model!
        m.queueMove(MoveDirection.Right
            , completion: { (changed: Bool) -> () in
                if changed {
                    self.followUp()
                }
        })
    }
    
    @objc(down:)
    func downCommand(r:UIGestureRecognizer){
        assert(model != nil)
        let m = model!
        m.queueMove(MoveDirection.Down
            , completion: { (changed: Bool) -> () in
                if changed {
                    self.followUp()
                }
        })
    }
    
    func followUp(){
        assert(model != nil)
        let m = model!
        let(userWon, woncoords) = m.userHasWon()
        
        if userWon{
            let alertView = UIAlertView()
            alertView.title = "Victory"
            alertView.message = "You win"
            alertView.addButtonWithTitle("Cancel")
            alertView.show()
        }
        
        let randomNum = Int(arc4random_uniform(10))
        m.insertTileAtRandomLocation(randomNum == 1 ? 4: 2)
        
        if m.userHasLost(){
            let alertView = UIAlertView()
            alertView.title = "Defeat"
            alertView.message = "You lost"
            alertView.addButtonWithTitle("Cancel")
            alertView.show()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
