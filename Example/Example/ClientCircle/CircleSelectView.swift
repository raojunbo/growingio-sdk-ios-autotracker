//
// CircleSelectView.swift
// Example
//
//  Created by rjb on 2020/11/3.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


import UIKit

class CircleSelectCoverView: UIView {
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor =  UIColor(red: 220/255.0, green: 50/255.0, blue: 35/255.0, alpha: 0.5)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 220/255.0, green: 50/255.0, blue: 35/255.0, alpha: 1).cgColor
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CircleSelectView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = frame.width/2.0
        self.layer.masksToBounds = true
        self.backgroundColor =  UIColor(red: 220/255.0, green: 50/255.0, blue: 35/255.0, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
