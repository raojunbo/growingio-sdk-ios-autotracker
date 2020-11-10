//
// VisualNode.swift
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

class VisualUIViewNode: VisualNodeProtocal {
    /// Node节点所属的view
    weak var carrier:UIView?
    
    
    init(carrier:UIView) {
        self.carrier = carrier
    }
    
    /// 计算”该节点“在其父响应者的子节点中，”该节点“所所的index
    /// - Returns: index
    var visualNodeKeyIndex:Int {
        let classString = String(describing: Self.self)
        var subResponder: [AnyHashable]? = nil
        let next = self.carrier?.next
        if next is UISegmentedControl {
            #warning("这里需要将growingHelper_getIvar 改为inout。方便对subResponder的数组的修改")
            //            next?.growingHelper_getIvar("_segments", outObj: <#T##AutoreleasingUnsafeMutablePointer<AnyObject?>!#>)
            
        } else if next is UIView {
            //如果下一个响应者是UIView。subResponder为子views
            subResponder = (next as? UIView)?.subviews
        }
        
        var count = 0
        var index = -1
        for res in subResponder ?? [] {
            guard let res = res as? UIResponder else {
                continue
            }
            //父响应者的subViews里有本身类型相同的话count+1
            if classString == String(describing: type(of: res)) {
                count += 1
            }
            if res == self.carrier {
                index = count - 1
            }
        }
        return index
    }
    
    /// 该节点的所形成的PATH，规则：类名[index]
    /// - Returns: PATH
    var visualNodeSubPath: String? {
        /* 忽略路径 UITableViewWrapperView 为 iOS11 以下 UITableView 与 cell 之间的 view */
        guard let carrier = carrier else {
            return nil
        }
        let carrierClassName = NSStringFromClass(type(of:carrier))
        if carrierClassName == "UITableViewWrapperView" {
            return ""
        }

        let index = visualNodeKeyIndex
        return index < 0 ? carrierClassName: String(format: "%@[%ld]", carrierClassName, index)
    }
    
    var visualNodeName:String? {
        return visualNodeClassName
    }
    
    var visualNodeClassName:String? {
        guard let carrier = carrier else {
            return nil
        }
        return NSStringFromClass(type(of:carrier))
    }
    
    /// Node节点的父节点
    var parentNode:VisualNodeProtocal? {
        //如果当前carrier的next是vc
        let nextResponder = carrier?.next
        if  let vcResponder = nextResponder as? UIViewController  {
            return vcResponder.node
        }
        //当前carrier的next不是vc。那么superview为父节点
        if let superView = carrier?.superview {
            return superView.node
        }
        return nil
    }
    
    var visualNodeFrame:CGRect {
        return carrier?.frame ?? CGRect.zero
    }
}


/// TableViewHeaderFooterView
class VisualUITableViewHeaderFooterViewNode: VisualUIViewNode {
    
//    func growingNodeSubPath() -> String? {
//        var tableView = carrier?.superview as? UITableView
//        
//        while !(tableView is UITableView) {
//            tableView = tableView?.superview as? UITableView
//            if tableView == nil {
//                return carrier?.superview?.node?.visualNodeSubPath
//            }
//        }
//        for i in 0..<(tableView?.numberOfSections ?? 0) {
//            if carrier == tableView?.headerView(forSection: i) {
//                return String(format: "%@[%ld]", NSStringFromClass(UITableViewHeaderFooterView.self), i)
//            }
//            if carrier == tableView?.footerView(forSection: i) {
//                return String(format: "%@[%ld]", NSStringFromClass(UITableViewHeaderFooterView.self), i)
//            }
//        }
//        return carrier?.superview?.node?.visualNodeSubPath
//    }
}
