//
//  DiamondsImageView.swift
//  ClearGame
//
//  Created by yechu on 17/3/13.
//  Copyright © 2017年 lisey_lee. All rights reserved.
//

import UIKit

class DiamondsImageView: UIImageView {
    var backgroundType : backgroundType = .clear
    var itemIndex : Int = 0
    
    //起始位置和将要移动时的位置，动画效果
    var currentLocation : CGPoint?
    var toLocation : CGPoint?
    
    typealias returnIndexAndType = (Int, backgroundType) -> ()
    var returnTuple : returnIndexAndType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        currentLocation = frame.origin
        
        //添加单击手势
        addTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(touchInside))
        gesture.numberOfTapsRequired = 1
        self.isUserInteractionEnabled = true
        
        self.addGestureRecognizer(gesture)
    }
    
    func touchInside(_ sender: UITapGestureRecognizer) {
//        //将自己所在颜色的块都清除掉
//        print("点击 type = \(backgroundType), index = \(itemIndex)")
        
        //点击空白方块，则不响应
        if backgroundType == .clear {
            print("不能点击")
            return
        }
        
        //点击颜色方块，将方块信息传递给viewController
        if let tuple = returnTuple {
            tuple(itemIndex, backgroundType)
        }
    }
}
