//
// VisualNodeManager.swift
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

/// 主要是管理Node节点的生成
class VisualViewNodeManager {
    static func createViewNode(_ view:UIView)  {
      
        var node = view.node
       
        if node == nil {
            //针对不同的view绑定不同的Node
            if view is UITableViewCell {
                node = VisualUITableViewCellNode.init(carrier: view)
            } else {
                node = VisualUIViewNode.init(carrier: view)
            }
            view.node = node
        }
    }
}
