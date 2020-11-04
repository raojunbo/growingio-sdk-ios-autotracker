//
// UILabelExtensions.swift
// Example
//
//  Created by rjb on 2020/11/4.
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


import Foundation
import UIKit

// MARK: - Methods
public extension UILabel {
    /// SwifterSwift: Initialize a UILabel with text
    convenience init(text: String?) {
        self.init()
        self.text = text
    }

    /// SwifterSwift: Initialize a UILabel with a text and font style.
    ///
    /// - Parameters:
    ///   - text: the label's text.
    ///   - style: the text style of the label, used to determine which font should be used.
    convenience init(text: String, style: UIFont.TextStyle) {
        self.init()
        font = UIFont.preferredFont(forTextStyle: style)
        self.text = text
    }

    /// SwifterSwift: Required height for a label
    var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = self.lineBreakMode
//        label.lineBreakMode =  NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
}

