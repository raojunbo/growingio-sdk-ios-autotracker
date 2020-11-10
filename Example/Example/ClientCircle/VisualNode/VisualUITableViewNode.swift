//
// VisualUITableViewNode.swift
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

class VisualUITableViewNode: VisualUIViewNode {
    
    
}

class VisualUITableViewCellNode: VisualUIViewNode {
    override var visualNodeKeyIndex:Int {
        return visualNodeIndexPath?.row ?? 0
    }
    
    var visualNodeIndexPath: IndexPath? {
        guard let cell = carrier as? UITableViewCell else {
            return nil
        }
        //一直向上找，找到其UITableView时，开始计算indexPath
        var tableView = cell.superview
        while tableView != nil {
            if let tmpTableView = tableView as? UITableView {
                let indexPath = tmpTableView.indexPath(for: cell)
                return indexPath
            }
            tableView = tableView?.superview
        }
        return nil
    }
    
    override var visualNodeSubPath: String? {
        guard let carrier = carrier else {
            return nil
        }
        let indexpath = visualNodeIndexPath
        if let indexpath = indexpath {
            return String(format: "Section[%ld]/%@[%ld]", indexpath.section, NSStringFromClass(type(of: carrier)), indexpath.row)
        }
        return super.visualNodeSubPath
    }
    
    override var visualNodeName:String? {
        return "列表项"
    }
}

