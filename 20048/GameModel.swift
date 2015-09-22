//
//  GameModel.swift
//  20048
//
//  Created by Di on 8/19/15.
//  Copyright (c) 2015 Di. All rights reserved.
//

import UIKit

protocol GameModelProtocol: class{
    func scoreChanged(score: Int)
    func moveOneTile(from: (Int, Int), to: (Int,Int), value: Int)
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
    func insertTile(location: (Int, Int), value: Int)
}

class GameModel: NSObject {
    
    let dimension: Int
    let threshold: Int
    var gameboard: SquareGameboard<TileObject>
    
    var queue: [MoveCommand]
    var timer: NSTimer
    let delegate: GameModelProtocol
    
    let maxCommands = 100
    let queueDelay = 0.3
    
    var score: Int = 0 {
        didSet{
            delegate.scoreChanged(score)
        }
    }
    
    init(dimension d:Int, threshold t: Int, delegate: GameModelProtocol ){
        dimension = d
        threshold = t
        
        self.delegate = delegate
        gameboard = SquareGameboard(dimension: d, value: .Empty)
        queue = [MoveCommand]()
        timer = NSTimer()
        super.init()
        
    }
    
    func queueMove(direction: MoveDirection, completion: (Bool) -> ()){
        if queue.count > maxCommands{
            return
        }
        
        let command = MoveCommand(d: direction, c: completion)
        queue.append(command)
        if !timer.valid{
            timerFired(timer)
        }
    }
    
    func timerFired(timer: NSTimer){
        
        if queue.count == 0{
            return
        }
        
        var changed = false
        
        while queue.count > 0 {
            let command = queue[0]
            queue.removeAtIndex(0)
            changed = perform(command.direction)
            
            command.completion(changed)
            
            if changed {
                break
            }
        }//end while
        
        if changed{
            self.timer = NSTimer.scheduledTimerWithTimeInterval(queueDelay,
                target: self,
                selector: Selector("timerFired:"),
                userInfo: nil,
                repeats: false)
        }
    }
    
    
    
    func perform(direction: MoveDirection) -> Bool {
        let coordinateGenerator: (Int) -> [(Int, Int)] = { (iter: Int) -> [(Int, Int)] in
            var buffer = Array<(Int, Int)>(count: self.dimension, repeatedValue: (0, 0))
            for i in 0..<self.dimension{
                switch direction{
                case .Up:    buffer[i] = (i, iter)
                case .Down:  buffer[i] = (self.dimension - i - 1, iter)
                case .Left:  buffer[i] = (iter, i)
                case .Right: buffer[i] = (iter, self.dimension - i - 1)
                }
            }
            return buffer
        }
        
        var atLeastOneMove = false
        
        for i in 0..<self.dimension{
            let coords = coordinateGenerator(i)
            
            let tiles = coords.map(){ (c: (Int, Int)) -> TileObject in
                let (x, y) = c
                return self.gameboard[x, y]
            }
            
            let orders = merge(tiles)
            atLeastOneMove = orders.count > 0 ? true : atLeastOneMove
            
            //unfinished part
            for ob in orders{
                switch ob{
                case let .SingleMoveOrder(s, d, v, isMerge):
                    let (sx, sy) = coords[s]
                    let (dx, dy) = coords[d]
                    if isMerge{
                        score += v
                    }
                    
                    gameboard[sx, sy] = TileObject.Empty
                    gameboard[dx, dy] = TileObject.Tile(v)
                    delegate.moveOneTile(coords[s],  to: coords[d], value: v)
                case let .DoubleMoveOrder(s1, s2, d, v):
                    let (s1x, s1y) = coords[s1]
                    let (s2x, s2y) = coords[s2]
                    let (dx, dy) = coords[d]
                    score += v
                    gameboard[s1x, s1y] = TileObject.Empty
                    gameboard[s2x, s2y] = TileObject.Empty
                    gameboard[dx, dy] = TileObject.Tile(v)
                    delegate.moveTwoTiles((coords[s1], coords[s2]), to: coords[d], value: v)
                }
            }
        }
        return atLeastOneMove
    }
    
    func merge(group: [TileObject]) -> [MoveOrder]{
        return convert(collapse(condense(group)))
    }
    
    
    func condense(group: [TileObject]) -> [ActionToken]{
        
        var tokenBuffer = [ActionToken]()
        
        for (idx, tile) in enumerate(group){
            switch tile{
            case let .Tile(value) where tokenBuffer.count == idx:
                tokenBuffer.append(ActionToken.NoAction(source: idx, value: value))
            case let .Tile(value):
                tokenBuffer.append(ActionToken.Move(source: idx, value: value))
            default:
                break
            }
        }
        return tokenBuffer
    }
    
    class func quiescentTileStillQuiescent(inputPosition: Int, outputLength: Int) -> Bool{
        return inputPosition == outputLength
    }
    
    func collapse(group: [ActionToken]) -> [ActionToken]{
        
        var tokenBuffer = [ActionToken]()
        var skipNext = false
        
        for (idx, token) in enumerate(group){
            
            if skipNext {
                skipNext = false
                continue
            }
            
            switch token{
            case .SingleCombine:
                assert(false, "can't be single")
            case .DoubleCombine:
                assert(false, "can't be double")
            case let .NoAction(s, v)
                where (idx < group.count - 1
                    && v == group[idx + 1].getValue()
                    && GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count)):
                let next = group[idx + 1]
                let nv = v + group[idx + 1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.SingleCombine(source: next.getSource(), value: nv))
            case let t where (idx < group.count-1 && t.getValue() == group[idx + 1].getValue()):
                let next = group[idx + 1]
                let nv = t.getValue() + group[idx + 1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.DoubleCombine(firstSource: t.getSource(), secondSource: next.getSource(), value: nv))
            case let .NoAction(s,v) where !GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count):
                tokenBuffer.append(ActionToken.Move(source: s, value: v))
            case let .NoAction(s,v):
                tokenBuffer.append(ActionToken.NoAction(source: s, value: v))
            case let .Move(s, v):
                tokenBuffer.append(ActionToken.Move(source: s, value: v))
            default:
                break
            }
        }
        return tokenBuffer
    }
    
    func convert(group: [ActionToken]) -> [MoveOrder]{
        
        var moveBuffer = [MoveOrder]()
        for (idx, m) in enumerate(group){
            switch m{
            case let .Move(s,v):
                moveBuffer.append(MoveOrder.SingleMoveOrder(source: s, destination: idx, value: v, isMerged: false))
            case let .SingleCombine(s,v):
                moveBuffer.append(MoveOrder.SingleMoveOrder(source: s, destination: idx, value: v, isMerged: true))
            case let .DoubleCombine(s1, s2, v):
                moveBuffer.append(MoveOrder.DoubleMoveOrder(firstSource: s1, secondSource: s2, destination: idx, value: v))
            default:
                break
            }
        }
        return moveBuffer
    }
    
    
    //Mark: Protocal implement
    func userHasWon() -> (Bool, (Int, Int)?){
        
        for i in 0..<self.dimension{
            for j in 0..<self.dimension{
                switch gameboard[i, j]{
                case let .Tile(v) where v >= threshold:
                    return (true, (i, j))
                default:
                    continue
                }
            }
        }
        return (false, nil)
    }
    
    
    func userHasLost() -> Bool {
        if !gameboardFull(){
            return false
        }
        
        for i in 0..<self.dimension{
            for j in 0..<self.dimension{
                switch gameboard[i, j]{
                case .Empty:
                    assert(false, "not empty")
                case let .Tile(v):
                    if tileBelowHasSameValue((i, j), v) || tileRightHasSameValue((i, j), v){
                        return false
                    }
                }
                
            }
        }
        return true
    }
    
    func gameboardFull() -> Bool{
        return findEmptySpots().count == 0
    }
    
    func findEmptySpots() -> [(Int, Int)]{
        var buffer = Array<(Int, Int)>()
        
        for i in 0..<self.dimension{
            for j in 0..<self.dimension{
                switch gameboard[i, j]{
                case .Empty:
                    buffer.append((i, j))
                case .Tile:
                    break
                }
            }
        }
        return buffer
    }

    func tileBelowHasSameValue(location: (Int, Int), _ value: Int) -> Bool{
        let (x, y) = location
        if y == self.dimension - 1 {
            return false
        }
        
        switch gameboard[x, y+1]{
        case let .Tile(v):
            return v == value
        default:
            return false
        }
    }
    
    func tileRightHasSameValue(location: (Int, Int), _ value: Int) -> Bool{
        let (x, y) = location
        if x == self.dimension - 1{
            return false
        }
        switch gameboard[x+1, y]{
        case let .Tile(v):
            return v == value
        default:
            return false
        }
        
    }
    
    //implement delegate
    
    func insertTile(pos:(Int, Int), value: Int){
        
        let (x, y) = pos
        switch gameboard[x, y]{
        case .Empty:
            gameboard[x, y] = TileObject.Tile(value)
            delegate.insertTile(pos, value: value)
        case .Tile:
            break
        }
    }
    
    func insertTileAtRandomLocation(value: Int){
        let openSpots = findEmptySpots()
        
        if openSpots.count == 0{
            return
        }
        
        let idx = Int(arc4random_uniform(UInt32(openSpots.count-1)))
        let (x,y) = openSpots[idx]
        insertTile((x, y), value: value)
    }
}
