//
// VisualNodeHelper.swift
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

class VisualNodeHelper {
//    class func xPath(for node: VisualNodeProtocal?) -> String? {
//       return nil
//    }
    
    /// 计算UIView的xPath
    /// - Parameter view: 指定的view
    /// - Returns: 返回路径
    class func xPath(for view: UIView?) -> String? {
        var viewPathArray: [String] = []
        var node:VisualNodeProtocal? = view?.node
        //不断找父节点，直到父节点为空
        while node != nil {
            if let subPath = node?.visualNodeSubPath ,subPath.count > 0 {
                viewPathArray.append(subPath)
            }
            node = node?.parentNode
        }
        
        let path = viewPathArray.reversed().joined(separator: "/")
        let allPath = "/".appending(path)
        return allPath
    }

//    class func xPath(for vc: UIViewController?) -> String? {
//        guard let vc = vc else {
//            return nil
//        }
//        var vcTree:[VisualVCNode] = []
//        vcTree.append(vc.node as! VisualVCNode)
//
//        var parent = vc.parent
//        while parent != nil {
//            if let parentNode = parent?.node?.parentNode as? VisualVCNode {
//                vcTree.append(parentNode)
//            }
//            parent = parent?.parent
//        }
//
//        var path:String = ""
//        for item in vcTree {
//            let className = String(describing:type(of: item.carrier))
//            let subPath = "/\(className)"
//            path = "\(subPath)\(path)"
//        }
//
//        return path
//    }

}
