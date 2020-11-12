//
// VisualVCNode.swift
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

class VisualVCNode: VisualNodeProtocal{
    weak var carrier:UIViewController?
    var innerPath:String?
    
    init(carrier:UIViewController) {
        self.carrier = carrier
    }
    
    var parentNode: VisualNodeProtocal? {
        guard let carrier = carrier else {
            return nil
        }
        if !carrier.isViewLoaded {
            return nil
        }
        return carrier.parent?.node
    }
    
    var visualNodeKeyIndex: Int {
        guard let carrier = carrier else {
            return 0
        }
        let classType = type(of: carrier)
        var count = 0
        var index = -1
        if let subResponder = carrier.parent?.children {
            for res in subResponder {
                if classType ==  type(of: res) {
                    count = count + 1
                }
                if res == carrier {
                    index = count - 1;
                }
            }
        }
        
        if type(of: carrier) != UIAlertController.Type.self && count == 1{
            index = index - 1
        }
        return index
    }
    
    var visualNodeIndexPath: IndexPath? {
        return nil
    }
    
    var visualNodeSubPath: String? {

        guard let carrier = carrier else {
            return nil
        }
        
        let index = visualNodeKeyIndex
        let className = NSStringFromClass(type(of:carrier))
        return index < 0 ? className: String(format: "%@[%ld]", className, index)
    }
    
    var visualNodeName:String? {
        return "页面"
    }
}
