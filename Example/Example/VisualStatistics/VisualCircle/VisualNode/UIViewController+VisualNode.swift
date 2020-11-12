//
// UIViewController+VisualNode.swift
// Example
//
//  Created by rjb on 2020/11/8.
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

extension UIViewController {
    static func swizzleOnce() {
        UIViewController.swizzleMethod
    }
    
    private static let swizzleMethod: Void = {
        let originalSelector = #selector(viewWillAppear(_:))
        let swizzledSelector = #selector(visual_viewDidAppear(_:))
        swizzlingForClass(UIViewController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }()
    
    @objc func visual_viewDidAppear(_ animated:Bool) {
        handleViewDidAppear()
        visual_viewDidAppear(animated)
    }
    
    func handleViewDidAppear()  {
        VisualVCNodeManager.createVCNode(self)
    }
}

extension UIViewController {
    
    /// 给一个view一个截图
    /// - Parameter maxScale: Scale
    /// - Returns: 返回一个图片
    func visualScreenshot(_ maxScale: CGFloat) -> UIImage? {
        return self.view.visualScreenshot(maxScale)
    }
}


