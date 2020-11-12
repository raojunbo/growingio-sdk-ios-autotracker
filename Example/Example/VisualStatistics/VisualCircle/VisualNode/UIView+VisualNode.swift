//
// UIView+VisualNode.swift
// Example
//
//  Created by rjb on 2020/11/7.
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

extension UIView {
    static func swizzleOnce() {
        UIView.swizzleMethod
    }
    
    private static let swizzleMethod: Void = {
        let originalSelector = #selector(didMoveToSuperview)
        let swizzledSelector = #selector(visual_didMoveToSuperview)
        swizzlingForClass(UIView.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }()

    @objc func visual_didMoveToSuperview() {
        handleDidMoveToSuperView()
        visual_didMoveToSuperview()
    }
    
    func handleDidMoveToSuperView()  {
        //在UIView被添加到父视图时，在这里做节点的绑定
        VisualViewNodeManager.createViewNode(self)
    }
}

extension UIView {
    
    /// 给一个view一个截图
    /// - Parameter maxScale: Scale
    /// - Returns: 返回一个图片
    func visualScreenshot(_ maxScale: CGFloat) -> UIImage? {
        let view = self

        var scale = UIScreen.main.scale
        if maxScale != 0 && maxScale < scale {
            scale = maxScale
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        if let context = context {
            view.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
