//
//  LoopTest.swift
//  ClearGame
//
//  Created by yechu on 17/3/20.
//  Copyright © 2017年 lisey_lee. All rights reserved.
//

import Foundation

struct LoopTest {
    private var column : Int = 0
    private var printArray : [[Int]]
    
    init(arrayColumn: Int) {
        column = arrayColumn
        printArray = [[]]
    }
    
    private mutating func setPrintArray() {
        let firstArray = Array(repeating: 0, count: column)
        printArray[0] = firstArray
        
        for _ in 1..<column {
            let array = Array(repeating: 0, count: column)
            
            printArray.append(array)
        }
    }
    
    private mutating func getArroundPrintArray() {
        setPrintArray()
        var index = 1
        
        for i in 1...column {
            index = setOneArround(round: i, item: index)
        }
    }
    
    mutating func printArround() {
        getArroundPrintArray()
        let length = getLength(item: column * column)
        
        for i in 1...column {
            let array = printArray[i - 1]
            for item in array {
                let spaceLength = length - getLength(item: item)
                var space = ""
                
                if spaceLength >= 1 {
                    for _ in 1...spaceLength {
                        space += " "
                    }
                }
                
                print ("\(space)\(item)", terminator: " ")
            }
            
            print()
        }
        
        print()
    }
    
    private func getLength(item: Int) -> Int {
        var index = item
        var length = 0
        
        repeat {
            index = index / 10
            length = length + 1
        }while index >= 1
        
        return length
    }
    
    /// 画一圈
    ///
    /// - parameter round: 圈数
    /// - parameter item:  数值
    ///
    /// - returns: 下一圈的第一个数值
    private mutating func setOneArround(round: Int, item: Int) -> Int {
        var currentItem = item
        //上横
        var array = printArray[round - 1]
        
        for (index,curItem) in array.enumerated() {
            if curItem == 0 {
                array[index] = currentItem
                currentItem = currentItem + 1
            }
        }
        
        printArray[round - 1] = array
        
        //右竖
        for index in round..<printArray.count {
            var itemArray = printArray[index]
            
            if itemArray[column - round] == 0 {
                itemArray[column - round] = currentItem
                currentItem = currentItem + 1
                
                printArray[index] = itemArray
            }
        }
        
        //下横
        array = printArray[column - round]
        
        for (index,curItem) in array.enumerated().reversed() {
            if curItem == 0 {
                array[index] = currentItem
                currentItem = currentItem + 1
            }
        }
        
        printArray[column - round] = array
        
        //左竖
        for index in round..<printArray.count {
            var itemArray = printArray[column - index]
            
            if itemArray[round - 1] == 0 {
                itemArray[round - 1] = currentItem
                currentItem = currentItem + 1
                
                printArray[column - index] = itemArray
            }
        }
        
        return currentItem
    }
}
