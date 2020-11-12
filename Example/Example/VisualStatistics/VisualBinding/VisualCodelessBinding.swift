//
// VisualEventBinding.swift
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
import SwiftyJSON

class VisualCodelessBinding : NSObject{
    
    /// 绑定内部id
    var name: String
    /// 路径的解析
    var path: VisualObjectSelector
    /// 事件名字
    var eventName: String
    /// 所绑定的类
    var swizzleClass: AnyClass!
    var running: Bool

    
    init(eventName: String, path: String) {
        self.eventName = eventName
        self.path = VisualObjectSelector(string: path)
        self.name = UUID().uuidString
        self.running = false
        self.swizzleClass = nil
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? VisualCodelessBinding else {
            return false
        }

        if object === self {
            return true
        } else {
            return self.eventName == object.eventName && self.path == object.path
        }
    }

    override var hash: Int {
        return eventName.hash ^ path.hash
    }

    func execute() {}

    func stop() {}
    
}
