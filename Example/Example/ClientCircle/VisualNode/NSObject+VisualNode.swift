//
// NSObject+VisualNode.swift
// Example
//
//  Created by rjb on 2020/11/10.
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

extension NSObject {
    /// node 关联的key
    static var kVisualNode:Void?
    
    /// 给UIView绑定一个node
    var node:VisualNodeProtocal? {
        get {
            return objc_getAssociatedObject(self, &UIView.kVisualNode) as? VisualNodeProtocal
        }
        set {
            objc_setAssociatedObject(self, &UIView.kVisualNode, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
