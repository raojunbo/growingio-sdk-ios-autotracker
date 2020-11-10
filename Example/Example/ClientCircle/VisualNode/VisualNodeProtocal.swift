//
// VisualNodeProtocal.swift
// Example
//
//  Created by rjb on 2020/11/6.
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

protocol VisualNodeProtocal {
    /// 一种class类型的node在其父视图中的唯一index位置，eg: UIButton[0] UIButton[1]
    /// UILabel[0] UILabel[1]
    var visualNodeKeyIndex: Int { get }
    /// 只有UITableView UICollectionView才有的indexpath
    var visualNodeIndexPath: IndexPath? { get }
    /// 完整的xpath由各个node的subPath拼接而成
    var visualNodeSubPath: String? { get }
    /// 节点的中文名字
    var visualNodeName:String? { get }
    /// 节点的carrier类名
    var visualNodeClassName:String? { get }
    /// 节点的carrier的父亲的绑定的节点
    var parentNode:VisualNodeProtocal? { get }
    
    /// 节点的carrier的大小
    var visualNodeFrame:CGRect { get }
}

extension VisualNodeProtocal {
    var visualNodeKeyIndex: Int {
        return 0
    }
    
    var visualNodeIndexPath: IndexPath? {
        return nil
    }
    
    var visualNodeSubPath: String? {
        return nil
    }
    
    var visualNodeName:String? {
        return nil
    }
    
    var visualNodeClassName:String? {
        return nil
    }
    
    var visualNodeFrame:CGRect {
        return CGRect.zero
    }
    
}
