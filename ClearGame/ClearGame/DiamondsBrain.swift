//
//  DiamondsBrain.swift
//  ClearGame
//
//  Created by yechu on 17/3/13.
//  Copyright © 2017年 lisey_lee. All rights reserved.
//

import Foundation

//let DiamondsArrayLegth = 35
//let ColumnCount = 5

struct DiamondsBrain {
    typealias returnMoveExchange = (Int, Int) -> ()
    var returnExchange : returnMoveExchange?
    
    var score = 0
    
    let scoreRange = [(0, 5, 8), (5, 10, 10), (10, 15, 12), (15, 20, 14), (20, 25, 16), (25, 30, 18), (30, 35, 20)]
    
    var diamondsArray : [Int] = [
        0, 0, 3, 1, 0,
        1, 0, 2, 1, 2,
        3, 0, 1, 1, 2,
        3, 3, 3, 1, 3,
        0, 2, 2, 1, 2,
        3, 3, 2, 1, 2,
        0, 3, 2, 1, 3
    ]
    
    var clearItemArray = Array<Int>(repeating: 0, count: DiamondsArrayLegth)
    var emptyColumnArray = Array<Int>(repeating: 0, count: ColumnCount)

    mutating func resetClearItemArray() {
        clearItemArray = Array<Int>(repeating: 0, count: DiamondsArrayLegth)
    }
    
    mutating func resetDiamondsArray() {
        for index in 0..<DiamondsArrayLegth {
            diamondsArray[index] = Int(arc4random() % 4)
        }
        
        resetClearItemArray()
        emptyColumnArray = Array<Int>(repeating: 0, count: ColumnCount)
        score = 0
    }
    
    func getScore() -> Int {
        return score
    }
    
    mutating func findSameTypeWithRound(type: Int, index: Int) {
        clearItemArray[index] = 1
        
        let isLeft = isLeftSame(type: type, index: index)
        if isLeft {
            findSameTypeWithRound(type: type, index: index - 1)
        }
        
        let isRight = isRightSame(type: type, index: index)
        if isRight {
            findSameTypeWithRound(type: type, index: index + 1)
        }
        
        let isUp = isUpSame(type: type, index: index)
        if isUp {
            findSameTypeWithRound(type: type, index: index + ColumnCount)
        }
        
        let isDown = isDownSame(type: type, index: index)
        if isDown {
            findSameTypeWithRound(type: type, index: index - ColumnCount)
        }
        
        let count = getClearArray(index: index)
        setScore(count: count)
    }
    
    private mutating func setScore(count: Int) {
        for index in 0..<scoreRange.count {
            let (downScore, upScore, rate) = scoreRange[index]
            
            if count >= downScore && count < upScore {
                score = score + count * rate
                break
            }
        }
    }
    
    private mutating func getClearArray(index : Int) -> Int {
        var count = 0
        
        for item in clearItemArray {
            if item == 1 {
                count = count + 1
            }
        }
        
        if count < 2 {
            clearItemArray[index] = 0
            count = 0
        }
        
        return count
    }
    
    private mutating func isLeftSame(type: Int, index: Int) -> Bool {
        if index % ColumnCount == 0 || index - 1 < 0 || clearItemArray[index - 1] == 1 || diamondsArray[index - 1] == -1 {
            return false
        }
        
        let leftCloumn = (index - 1) % ColumnCount;
        
        if leftCloumn >= 0 {
            let leftType = diamondsArray[index - 1]
            
            if leftType == type {
                clearItemArray[index - 1] = 1
                
                return true
            }
        }
        
        return false
    }
    
    private mutating func isRightSame(type: Int, index: Int) -> Bool {
        if index % ColumnCount == 4 || index + 1 >= diamondsArray.count || clearItemArray[index + 1] == 1 || diamondsArray[index + 1] == -1{
            return false
        }
        
        let rightCloumn = (index + 1) %  ColumnCount;
        
        if rightCloumn <= ColumnCount {
            let leftType = diamondsArray[index + 1]
            
            if leftType == type {
                clearItemArray[index + 1] = 1
                return true
            }
        }
        
        return false
    }
    
    private mutating func isUpSame(type: Int, index: Int) -> Bool {
        let upRow = index / ColumnCount + 1;
        
        if index + ColumnCount >= diamondsArray.count || clearItemArray[index + ColumnCount] == 1 || diamondsArray[index + ColumnCount] == -1 {
            return false
        }
        
        if upRow <= 7 {
            let leftType = diamondsArray[index + ColumnCount]
            
            if leftType == type {
                clearItemArray[index + ColumnCount] = 1
                return true
            }
        }
        
        return false
    }
    
    private mutating func isDownSame(type: Int, index: Int) -> Bool {
        if index - ColumnCount < 0 || clearItemArray[index - ColumnCount] == 1 || diamondsArray[index - ColumnCount] == -1 {
            return false
        }
        
        let downRow = index / ColumnCount - 1;
        
        if downRow >= 0 {
            let leftType = diamondsArray[index - ColumnCount]
            
            if leftType == type {
                clearItemArray[index - ColumnCount] = 1
                return true
            }
        }
        
        return false
    }
    
    private mutating func fineEmptyColumn() -> Int {
        var isEmptyColumn = 0
        
        for (index, item) in diamondsArray.enumerated() {
            if index < ColumnCount {
                switch item {
                case -1:
                    emptyColumnArray[index] = 1
                    isEmptyColumn = isEmptyColumn + 1
                default:
                    break
                }
            }
        }
        
        return isEmptyColumn
    }
    
    mutating func moveColumn() {
        let isEmptyColumn = fineEmptyColumn()
        
        if isEmptyColumn > 0 && isEmptyColumn < 4 {
            for index in 0..<ColumnCount {
                let item = emptyColumnArray[index]
                switch item {
                case 1:
                    for rightIndex in index + 1..<ColumnCount {
                        //always want to find a colum to exchange
                        if isHaveRight(index: rightIndex) {
                            moveDiamondsColumn(from: rightIndex, to: index)
                            break
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    private mutating func isHaveRight(index: Int) -> Bool {
        if index < ColumnCount {
            
            if emptyColumnArray[index] != 1 {
                return true
            }
        }
        
        return false
    }
    
    private mutating func moveDiamondsColumn(from: Int, to: Int) {
        if from < ColumnCount && to < ColumnCount {
            for i in 0..<7 {
                let fromIndex = i * ColumnCount + from
                let toIndex = i * ColumnCount + to
                
                if diamondsArray[fromIndex] == -1 {
                    break
                }
                
                diamondsArray[toIndex] = diamondsArray[fromIndex]
                diamondsArray[fromIndex] = -1
                
                if let exchange = returnExchange {
                    exchange(fromIndex, toIndex)
                }
            }
            
            emptyColumnArray[from] = 1;
            emptyColumnArray[to] = 0
        }
    }
    
    mutating func isGameOver() -> Bool {
        for (index, item) in diamondsArray.enumerated() {
            if item != -1 {
                let isLeft = isLeftSame(type: item, index: index)
                let isRight = isRightSame(type: item, index: index)
                let isUp = isUpSame(type: item, index: index)
                let isDown = isDownSame(type: item, index: index)
                
                if isLeft || isRight || isUp || isDown {
                    
                    return false
                }
            }
        }
        
        return true
    }
}
