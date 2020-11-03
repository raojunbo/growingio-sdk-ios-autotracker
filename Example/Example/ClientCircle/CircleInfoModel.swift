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

struct CircleViewModel {
    var top:Float?
    var left:Float?
    var width:Float?
    var height:Float?
    
    var xpath:String?
    var content:String?
    var nodeType:String?
}

struct CircleVcModel {
    var top:Float?
    var left:Float?
    var width:Float?
    var height:Float?
    var xpath:String?
}

struct CircleInfoModel {
    var viewInfo:CircleViewModel?
    var vcInfo:CircleVcModel?
}
 
