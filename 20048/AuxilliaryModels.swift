//
//  AuxilliaryModels.swift
//  20048
//
//  Created by Di on 8/19/15.
//  Copyright (c) 2015 Di. All rights reserved.
//



enum MoveDirection{
    case Up
    case Down
    case Left
    case Right
}


enum TileObject{
    case Empty
    case Tile(Int)
}


enum MoveOrder{
    case SingleMoveOrder(source: Int, destination: Int, value: Int, isMerged: Bool)
    case DoubleMoveOrder(firstSource: Int, secondSource: Int, destination: Int, value: Int)
}


enum ActionToken{

    case NoAction(source: Int, value: Int)
    case Move(source: Int, value: Int)
    case SingleCombine(source: Int, value: Int)
    case DoubleCombine(firstSource: Int, secondSource: Int, value: Int)
    
    func getValue() -> Int{
        switch self{
        case let .NoAction(_, v): return v
        case let .Move(_, v): return v
        case let .SingleCombine(_, v): return v
        case let .DoubleCombine(_, _, v): return v
        }
    }
    
    func getSource() -> Int {
        switch self{
        case let .NoAction(s, _): return s
        case let .Move(s, _): return s
        case let .SingleCombine(s, _): return s
        case let .DoubleCombine(s, _, _): return s
        }
    }
}


struct MoveCommand {
    var direction: MoveDirection
    var completion: (Bool) -> ()
    
    init(d: MoveDirection, c: (Bool) -> () ){
        direction = d
        completion = c
    }
}


struct SquareGameboard<T> {
    
    let dimension: Int
    var boardArray: [T]
    
    init(dimension d: Int, value: T){
        dimension = d
        boardArray = [T](count: d*d, repeatedValue: value)
    }
    
    subscript(row: Int, col: Int) -> T {
        get {
            assert(row>=0 && row < dimension)
            assert(col>=0 && col < dimension)
            
            return boardArray[row*dimension + col]
        }
        set {
            assert(row>=0 && row < dimension)
            assert(col>=0 && col < dimension)
            
            boardArray[row*dimension + col] = newValue

        }
    }
    
    
    mutating func setAll(item: T){
        for i in 0..<dimension{
            for j in 0..<dimension{
                self[i, j] = item
            }
        }
    }
        
}