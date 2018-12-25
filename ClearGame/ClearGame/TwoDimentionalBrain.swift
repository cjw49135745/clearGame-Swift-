//
//  TwoDimentionalBrain.swift
//  ClearGame
//
//  Created by yechu on 17/3/22.
//  Copyright © 2017年 lisey_lee. All rights reserved.
//

import Foundation

let ColumnCount = 6
let RowCount = 8

enum backgroundType {
    case yellow
    case blue
    case red
    case green
    case clear
}

struct TwoDimentionalBrain {
    //存储方块颜色
    private var sourceDataArray = [[backgroundType]]()
    //存储消除方块的单个分数值(count, value)
    private let scoreArray = [(0, 5), (5, 8), (10, 10), (13, 12), (15, 13), (100, 15)]
    //存储需要清除的方块 1：清除， 0：不清除
    private var clearArray = [(Int, Int)]()
    //存储需要移动的方块列
    private var emptyColumnArray = Array<Int>(repeating: 0, count: ColumnCount)
    //存储游戏分数
    var score = 0;
    
    //同列需要往下掉的方块，传递给viewController
    typealias exchangeRowInColumn = (Int, Int, Int) -> ()
    var itemMoveDown: exchangeRowInColumn?
    
    //需要整列移动的方块，传递给viewController
    typealias exchangeColumn = (Int, Int) -> ()
    var itemChangeColumn: exchangeColumn?
    
    mutating func setSourceDataArray() {
        //先清空
        sourceDataArray = [[backgroundType]]()
        
        for _ in 0..<RowCount {
            let array = setOneArray()
            
            sourceDataArray.append(array)
        }
    }
    
    func getSourceArray() -> [[backgroundType]] {
        return sourceDataArray;
    }
    
    private mutating func setOneArray() -> [backgroundType] {
        var array = [backgroundType]()
        for _ in 0..<ColumnCount {
            let data = arc4random() % 4
            
            switch data {
            case 0:
                array.append(.yellow)
            case 1:
                array.append(.blue)
            case 2:
                array.append(.red)
            case 3:
                array.append(.green)
            default:
                array.append(.clear)
            }
        }
        
        return array
    }
    
    mutating func getClearItem(row: Int, column: Int) {
        //先清空
        clearArray = [(Int, Int)]()
        clearArray.append((row, column))
        
        findSameTypeWithRound(row: row, column: column)
        
        if clearArray.count < 2 {
            clearArray = [(Int, Int)]()
            return;
        }
        
        for (row, column) in clearArray {
            //将需要消除的方块的颜色设置为透明
            sourceDataArray[row][column] = .clear
        }
        
        //计算分数
        let count = clearArray.count
        
        for (item, value) in scoreArray {
            if count >= item {
                score += value * count;
                break;
            }
        }
        
        //向下移动
        moveDown()
        //整列往中间移动
        moveCenter()
    }
    
    private mutating func moveDown() {
        for row in 0..<RowCount {
            for column in 0..<ColumnCount {
                if sourceDataArray[row][column] != .clear {
                    //寻找同列的下方是否有空的方块可以进行移动
                    let count = getUnClearUpCount(row: row - 1, column: column)
                    
                    if count > 0 {
                        //有，进行移动。
                        sourceDataArray[row - count][column] = sourceDataArray[row][column]
                        sourceDataArray[row][column] = .clear
                        
                        if let itemMD = itemMoveDown {
                            //传递给viewController itemMD(所在列, 原来的行, 需要移动到的行)
                            itemMD(column, row, row - count)
                        }
                    }
                }
            }
        }
    }
    
    private mutating func moveCenter() {
    //存在整列空了，两侧向中间移动
        var emptyCount = 0
        for column in 0..<ColumnCount {
            let empty = isEmpty(column: column)
            
            if empty {
                emptyCount += 1
            }
        }
        
        if emptyCount < 1 {
            return
        }
        
        let centerColumn = ColumnCount / 2
        
        //存储需要移动两列的列数间隔
        var count = 0
        for column in centerColumn + 1..<ColumnCount {
            if emptyColumnArray[column] == 1 {
                //如果是空的话，就加一
                count += 1
            }
            else if (count > 0) {
                //如果当前列不空，并且左侧有空的，则整列移动
                for i in 0..<ColumnCount - centerColumn {
                    if column + i < ColumnCount {
                        moveColumnToAnother(fromColumn: column + i, toColumn: column - count + i)
                    }
                }
                
                count = 0
            }
            else {
                //当前列不空，并且左侧没有空的，则什么都不做
            }
        }
        
        count = 0
        for index in 0...centerColumn {
            let column = centerColumn - index
            
            if emptyColumnArray[column] == 1 {
                count += 1
            }
            else if count > 0 {
                //如果当前列不空，并且右侧有空的，则整列移动
                for i in 0..<centerColumn {
                    if column - i >= 0 {
                        moveColumnToAnother(fromColumn: column - i, toColumn: column + count - i)
                    }
                }
                
                count = 0
            }
        }
        
        emptyColumnArray = Array<Int>(repeating: 0, count: ColumnCount)
    }
    
    private mutating func moveColumnToAnother(fromColumn: Int, toColumn: Int) {
        for row in 0..<sourceDataArray.count {
            sourceDataArray[row][toColumn] = sourceDataArray[row][fromColumn]
            sourceDataArray[row][fromColumn] = .clear
            
            emptyColumnArray[fromColumn] = 1
            emptyColumnArray[toColumn] = 0
            
            //传递给viewController
            if let changeColumn = itemChangeColumn {
                //changeColumn(当前的列, 移动后的列)
                changeColumn(fromColumn, toColumn)
            }
        }
    }
    
    private mutating func isEmpty(column: Int) -> Bool {
        for itemArray in sourceDataArray {
            if itemArray[column] != .clear {
                return false
            }
        }
        
        emptyColumnArray[column] = 1
        return true
    }
    
    private func getUnClearUpCount(row: Int, column: Int) -> Int {
        if row < 0 {
            //遇到边界
            return -1
        }
        
        var count = 0
        //遍历该列下方的所有方块
        for index in 0...row {
            if sourceDataArray[row - index][column] == .clear {
                //遇到空白方块，则间隔+1
                count = count + 1
            }
            else {
                //遇到有颜色的方块，则返回
                return count
            }
        }
        
        return count
    }
    
    private mutating func findSameTypeWithRound(row: Int, column: Int) {
        let isLeft = isLeftSame(row: row, column: column)
        //如果颜色一致，则继续往左边寻找相同颜色的方块
        if isLeft {
            findSameTypeWithRound(row: row, column: column  - 1)
        }
        
        let isRight = isRightSame(row: row, column: column)
        if isRight {
            findSameTypeWithRound(row: row, column: column + 1)
            
        }
        
        let isUp = isUpSame(row: row, column: column)
        if isUp {
            findSameTypeWithRound(row: row + 1, column: column)
        }
        
        let isDown = isDownSame(row: row, column: column)
        if isDown {
            findSameTypeWithRound(row: row - 1, column: column)
        }
    }
    
    private mutating func isLeftSame(row: Int, column: Int) -> Bool {
        if column <= 0 || isVisited(row: row, column: column - 1) {
            //如果已经是最左边或者已经访问过了
            return false
        }
        
        if sourceDataArray[row][column - 1] == .clear {
            //如果已经是空白方块
            return false
        }
        
        if sourceDataArray[row][column - 1] == sourceDataArray[row][column] {
            //左侧方块和当前方块的颜色一致，则将左侧方块的行与列坐标添加到clearArray
            clearArray.append((row, column - 1))
            return true
        }
        
        return false
    }
    
    private mutating func isRightSame(row: Int, column: Int) -> Bool {
        if column >= ColumnCount - 1 || isVisited(row: row, column: column + 1) {
            return false
        }
        
        if sourceDataArray[row][column + 1] == .clear {
            return false
        }
        
        if sourceDataArray[row][column + 1] == sourceDataArray[row][column] {
            clearArray.append((row, column + 1))
            return true
        }
        
        return false
    }
    
    private mutating func isUpSame(row: Int, column: Int) -> Bool {
        if row >= RowCount - 1 || isVisited(row: row + 1, column: column) {
            return false
        }
        
        if sourceDataArray[row + 1][column] == .clear {
            return false
        }
        
        if sourceDataArray[row + 1][column] == sourceDataArray[row][column] {
            clearArray.append((row + 1, column))
            return true
        }
        
        return false
    }
    
    private mutating func isDownSame(row: Int, column: Int) -> Bool {
        if row <= 0 || isVisited(row: row - 1, column: column) {
            return false
        }
        
        if sourceDataArray[row - 1][column] == .clear {
            return false
        }

        if sourceDataArray[row - 1][column] == sourceDataArray[row][column] {
            clearArray.append((row - 1, column))
            return true
        }
        
        return false
    }
    
    private func isVisited(row: Int, column: Int) -> Bool {
        for (itemRow, itemColumn) in clearArray {
            if itemRow == row && itemColumn == column {
                return true
            }
        }
        
        return false
    }
    
    mutating func isGameOver() -> Bool {
        //判断是否已经结束游戏了
        for row in 0..<RowCount {
            for column in 0..<ColumnCount {
                if sourceDataArray[row][column] == .clear {
                    //遇到空白方块，不执行下面的内容，继续下一次循环
                    continue;
                }
                
                //先清空，并把当前的方块添加到消除数组
                clearArray = [(Int, Int)]()
                clearArray.append((row, column))
                //在四个方向上寻找同颜色的方块
                findSameTypeWithRound(row: row, column: column)
                
                if clearArray.count >= 2 {
                    //存在连续的同颜色方块，游戏继续
                    return false
                }
            }
        }
        
        return true
    }
}
