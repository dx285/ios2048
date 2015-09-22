//
//  GameBoardView.swift
//  20048
//
//  Created by Di on 8/18/15.
//  Copyright (c) 2015 Di. All rights reserved.
//

import UIKit

class GameBoardView: UIView {
    
    let dimension: Int
    let tilePadding: CGFloat
    let tileWidth: CGFloat
    let cornerRadius: CGFloat
    
    var tiles: Dictionary<NSIndexPath, TileView>
    
    let decor = Decorator()
    
    let tilePopStartScale: CGFloat = 0.1
    let tilePopMaxScale: CGFloat = 1.1
    let tileExpandTime: NSTimeInterval = 0.18
    let tilePopDelay: NSTimeInterval = 0.05
    let tileShrinkTime: NSTimeInterval = 0.08
    let tileMergeStartScale: CGFloat = 1.0
    let tileMergeExpandTime: NSTimeInterval = 0.08
    let tileMergeShrinkTime: NSTimeInterval = 0.08
    
    let perSquareSlideDuration: NSTimeInterval = 0.08
    
    init(dimension d:Int, tileWidth tWidth: CGFloat, tilePadding tPadding:CGFloat, cornerRadius r:CGFloat, backgroundColor: UIColor, foregroundColor: UIColor){
        
        assert(d>0)
        dimension = d
        tilePadding = tPadding
        
        //test
        println("padding: \(tilePadding)")
        
        tileWidth = tWidth
        cornerRadius = r
        tiles = Dictionary()
        
        let sideLength = tilePadding + (CGFloat)(dimension)*(tilePadding + tileWidth)
        
        super.init(frame: CGRectMake(0, 0, sideLength, sideLength))
        layer.cornerRadius = r
        setBackground(backgroundColor: backgroundColor, tileColor: foregroundColor)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setBackground(backgroundColor bgColor: UIColor, tileColor: UIColor){
        backgroundColor = bgColor
        var xCursor = tilePadding
        var yCursor: CGFloat
        
        let bgRadius = cornerRadius >= 2 ? cornerRadius-2 : 0
        
        for i in 0..<dimension{
            yCursor = tilePadding
            for j in 0..<dimension{
                let backgroundView = UIView(frame: CGRectMake(xCursor, yCursor, tileWidth, tileWidth))
                
                backgroundView.backgroundColor = tileColor
                backgroundView.layer.cornerRadius = bgRadius
                
                addSubview(backgroundView)
                yCursor += tilePadding + tileWidth
                
            }
            xCursor += tileWidth + tilePadding
            
        }
    }
    
    func posIsValid(pos: (Int, Int)) -> Bool{
        let (x, y) = pos
        return (x>=0 && x<dimension && y>=0 && y<dimension)
    }
    
    
    func insertTile(pos: (Int, Int), value: Int){
        assert(posIsValid(pos))
        
        let (row, col) = pos
        let x = tilePadding + (CGFloat)(col)*(tileWidth + tilePadding)
        let y = tilePadding + (CGFloat)(row)*(tileWidth + tilePadding)
        let r = cornerRadius > 2 ? cornerRadius-2: 0
        
        let tile = TileView(position: CGPointMake(x, y), width: tileWidth, value: value, radius: r, delegate: decor)
        tile.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
        
        self.addSubview(tile)
        
        //Important
        bringSubviewToFront(tile)
        
        tiles[NSIndexPath(forRow: row, inSection: col)] = tile
        
        //add to board
        UIView.animateWithDuration(tileExpandTime,
            delay: tilePopDelay,
            options: UIViewAnimationOptions.TransitionNone,
            //pop the tile
            animations: { () -> Void in
                ///Reference to property 'tilePopMaxScale' in closure requires explicit 'self.' to make capture semantics explicit
                tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
            },
            //shrink back to normal size
            completion: { (finished: Bool) -> Void in
                UIView.animateWithDuration(self.tileShrinkTime,
                    animations:{ () -> Void in
                        tile.layer.setAffineTransform(CGAffineTransformIdentity)
                    }
                )
            }
        )
    }
    
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int){
        
        assert(posIsValid(from) && posIsValid(to))
        
        let fromKey = NSIndexPath(forRow: from.0, inSection: from.1)
        let toKey = NSIndexPath(forRow: to.0, inSection: to.1)
        
        assert(tiles[fromKey] != nil)
        
        let sTile = tiles[fromKey]!
        let eTile = tiles[toKey]
        
        var finalFrame = sTile.frame
        
        finalFrame.origin.x = tilePadding + (CGFloat)(to.1)*(tilePadding + tileWidth)
        finalFrame.origin.y = tilePadding + (CGFloat)(to.0)*(tilePadding + tileWidth)
        
        //update board state
        tiles.removeValueForKey(fromKey)
        tiles[toKey] = sTile
        
        //perform animate
        let shouldPop = eTile != nil
        
        UIView.animateWithDuration(perSquareSlideDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: { () -> Void in
                //slide tile
                sTile.frame = finalFrame
            },
            completion: { (finished: Bool) -> Void in
                sTile.value = value
                
                eTile?.removeFromSuperview()
                if !shouldPop || !finished  {
                //if !shouldPop {
                    return
                }
                
                sTile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                
                //pop tile
                UIView.animateWithDuration(self.tileMergeExpandTime,
                    animations:{ () -> Void in
                        sTile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                    },
                    completion:{ (finished: Bool) -> () in
                        UIView.animateWithDuration(self.tileMergeShrinkTime,
                            animations: { () -> Void in
                                sTile.layer.setAffineTransform(CGAffineTransformIdentity)
                            }
                        )
                    }
                )
            }
        )
    }
    
    
    func moveTwoTiles(from: ((Int, Int), (Int,Int)), to: (Int, Int), value: Int){
        assert(posIsValid(from.0) && posIsValid(from.1) && posIsValid(to))
        
//        let fromAKey = NSIndexPath(forRow: from.0.0, inSection: from.0.1)
//        let fromBKey = NSIndexPath(forRow: from.1.0, inSection: from.1.1)
//        let endKey = NSIndexPath(forRow: to.0, inSection: to.1)
        
        let (fromRowA, fromColA) = from.0
        let (fromRowB, fromColB) = from.1
        let (toRow, toCol) = to
        let fromAKey = NSIndexPath(forRow: fromRowA, inSection: fromColA)
        let fromBKey = NSIndexPath(forRow: fromRowB, inSection: fromColB)
        let endKey = NSIndexPath(forRow: toRow, inSection: toCol)
        
        assert(tiles[fromAKey] != nil)
        assert(tiles[fromBKey] != nil)
        
        let sATile = tiles[fromAKey]!
        let sBTile = tiles[fromBKey]!
        
        var finalFrame = sATile.frame
        
        finalFrame.origin.x = tilePadding + (CGFloat)(to.1)*(tilePadding + tileWidth)
        finalFrame.origin.y = tilePadding + (CGFloat)(to.0)*(tilePadding + tileWidth)
        
        //update the state
        let endTile = tiles[endKey]
        endTile?.removeFromSuperview()
        
        tiles.removeValueForKey(fromAKey)
        tiles.removeValueForKey(fromBKey)
        tiles[endKey] = sATile
        
        //update the view
        UIView.animateWithDuration(perSquareSlideDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: { () -> Void in
                sATile.frame = finalFrame
                sBTile.frame = finalFrame
            },
            completion: { (finished: Bool) -> Void in
                sATile.value = value
                sBTile.removeFromSuperview()
                
                if !finished {
                    return
                }
                sATile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                
                //pop tile
                UIView.animateWithDuration(self.tileMergeExpandTime,
                    animations: { () -> Void in
                        sATile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                    },
                    completion:{ (finished: Bool) -> Void in
                        UIView.animateWithDuration(self.tileMergeShrinkTime,
                            animations: { () -> Void in
                                sATile.layer.setAffineTransform(CGAffineTransformIdentity)
                        })
                        
                    }
                )
                
            }
        )
    }
    
    func reset(){
        
    }
}





