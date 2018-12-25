//
//  ViewController.swift
//  ClearGame
//
//  Created by yechu on 17/3/13.
//  Copyright © 2017年 lisey_lee. All rights reserved.
//

import UIKit

let ImageSpace : CGFloat = 4.0

class ViewController: UIViewController {
    //显示游戏得分
    @IBOutlet var scoreLabel: UILabel!
    
    let space : CGFloat = 20.0
    let width = (UIScreen.main.bounds.width - CGFloat(ColumnCount - 1) * ImageSpace - 40) / CGFloat(ColumnCount)
    let height = UIScreen.main.bounds.height
    
    //存储方块的数组
    private var imageArray = [[DiamondsImageView]]()
    //游戏逻辑的引用
    private var diamondsBrain = TwoDimentionalBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //获取随机方块颜色
        diamondsBrain.setSourceDataArray()
        
        //方块移动的实现方法
        weak var weakSelf = self
        diamondsBrain.itemMoveDown = {(column, fromRow, toRow) in
            weakSelf?.imageViewMoveDown(column: column, fromRow: fromRow, toRow: toRow)
        }
        diamondsBrain.itemChangeColumn = {(fromColunm, toColumn) in
            weakSelf?.imageViewExchangeColumn(fromColumn: fromColunm, toColumn: toColumn)
        }
        
        //创建方块
        createImageView()
        
        if diamondsBrain.isGameOver() {
            print("Game Over!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func createImageView() {
        //根据sourceDataArray的颜色创建方块
        let dataArray = diamondsBrain.getSourceArray()

        for (row, itemArray) in dataArray.enumerated() {
            var rowImageArray = [DiamondsImageView]()
            
            for (column, item) in itemArray.enumerated() {
                let originX = space + CGFloat(column) * (width + ImageSpace)
                let originY = height - CGFloat(row + 1) * (width + ImageSpace)
                let rect = CGRect(x: originX, y: originY, width: width, height: width)
                let imageView = DiamondsImageView(frame: rect)
                imageView.backgroundType = item
                imageView.itemIndex = row * ColumnCount + column
                
                weak var weakSelf = self
                imageView.returnTuple = {(index, type) in
                    let column = index % ColumnCount
                    let row = index / ColumnCount
                    weakSelf?.clearItem(row: row, column: column)
                }
                
                rowImageArray.append(imageView)
                self.view.addSubview(imageView)
            }
            
            imageArray.append(rowImageArray)
        }
        
        updateUI()
    }
    
    private func clearItem(row: Int, column: Int) {
        diamondsBrain.getClearItem(row: row, column: column)
        let dataArray = diamondsBrain.getSourceArray()
        
        for (row, itemArray) in dataArray.enumerated() {
            let rowImageArray = imageArray[row]
            
            for (column, item) in itemArray.enumerated() {
                rowImageArray[column].backgroundType = item
            }
        }
        
        updateUI()
        
        if diamondsBrain.isGameOver() {
            print("Game Over!")
        }
    }
    
    private func imageViewMoveDown(column: Int, fromRow: Int, toRow: Int) {
        let fromImage = imageArray[fromRow][column]
        let toImage = imageArray[toRow][column]
        
        exchangeImage(fromImage: fromImage, toImage: toImage)
        
        imageArray[fromRow][column] = toImage
        imageArray[toRow][column] = fromImage
    }
    
    private func imageViewExchangeColumn(fromColumn: Int, toColumn: Int) {
        for row in 0..<RowCount {
            if imageArray[row][fromColumn].backgroundType == .clear {
                return
            }
            else {
                let fromImage = imageArray[row][fromColumn]
                let toImage = imageArray[row][toColumn]
                exchangeImage(fromImage: fromImage, toImage: toImage)
                
                imageArray[row][fromColumn] = toImage
                imageArray[row][toColumn] = fromImage
            }
        }
    }
    
    private func exchangeImage(fromImage: DiamondsImageView, toImage: DiamondsImageView) {
        UIView.animate(withDuration: 0.2, animations: {
            let origin = fromImage.frame.origin
            fromImage.frame.origin = toImage.frame.origin
            toImage.frame.origin = origin
            
            })
        
        let index = fromImage.itemIndex
        fromImage.itemIndex = toImage.itemIndex
        toImage.itemIndex = index
    }
    
    @IBAction func resetGame(_ sender: UIButton) {
        diamondsBrain.setSourceDataArray()
        diamondsBrain.score = 0;
        
        let dataArray = diamondsBrain.getSourceArray()
        
        for (row, itemArray) in dataArray.enumerated() {
            var rowImageArray = imageArray[row]
            
            for (column, item) in itemArray.enumerated() {
                let originX = space + CGFloat(column) * (width + ImageSpace)
                let originY = height - CGFloat(row + 1) * (width + ImageSpace)
                let rect = CGRect(x: originX, y: originY, width: width, height: width)
                let imageView = rowImageArray[column]
                imageView.frame = rect
                imageView.backgroundType = item
                imageView.itemIndex = row * ColumnCount + column
                
                rowImageArray[column] = imageView
            }
            
            imageArray[row] = rowImageArray
        }

        updateUI()
    }
    
    private func updateUI() {
        let score = diamondsBrain.score;
        scoreLabel.text = String.init(stringInterpolationSegment: score)
        
        for (_, itemArray) in imageArray.enumerated() {
            for (_, item) in itemArray.enumerated() {
                switch item.backgroundType {
                case .green:
                    item.backgroundColor = UIColor.green
                case .red:
                    item.backgroundColor = UIColor.red
                case .blue:
                    item.backgroundColor = UIColor.blue
                case .yellow:
                    item.backgroundColor = UIColor.yellow
                case .clear:
                    item.backgroundColor = UIColor.clear
                }
            }
        }
    }
    
}

