//
//  BaseBlockButton.swift
//  Fitness
//
//  Created by Mac on 2018/3/22.
//  Copyright © 2018年 iOS. All rights reserved.
//

import UIKit

@objc class BaseBlockButton: UIButton {
  
    var block : ButtonCLickblock?
    //按钮点击block
    @objc   func addTapBlock(block:ButtonCLickblock?)
    {
        self.block = block
        self .addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    @objc func buttonClick()
    {
        self.block!()
    }

}
