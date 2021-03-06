//
// CircleInfoModel.swift
// Example
//
//  Created by rjb on 2020/11/3.
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

enum CircleNodeDisplayType:String {
    case CircleNodeDisplayVC = "VC"
    case CircleNodeDisplayCell = "CELL"
    case CircleNodeDisplayView = "VIEW"
}

struct CircleNodeModel {
    var displayType:CircleNodeDisplayType
    var belongToVC:String?
    var top:Float?
    var left:Float?
    var width:Float?
    var height:Float?
    
    var xpath:String?
    var nodeType:String?
    /// 类名
    var className:String?
    var nodeName:String?
    var content:String?
    var snapshot:UIImage?

    
    init(jsonData:JSON) {
        displayType = CircleNodeDisplayType(rawValue: jsonData["displayType"].stringValue) ?? CircleNodeDisplayType(rawValue: "VIEW")!
        top = jsonData["top"].floatValue
        left = jsonData["left"].floatValue
        width = jsonData["width"].floatValue
        height = jsonData["height"].floatValue
        
        xpath = jsonData["xpath"].stringValue
        
        content = jsonData["content"].stringValue
        nodeType = jsonData["nodeType"].stringValue
        className = jsonData["className"].stringValue
        nodeName = jsonData["nodeName"].stringValue
        
    }
}

struct CircleInfoModel {
    var infoArray:[CircleNodeModel] = []
}
 
