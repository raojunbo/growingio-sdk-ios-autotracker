//
// VisualNodeBinding.swift
// Example
//
//  Created by rjb on 2020/11/8.
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

/// 可视化统计的入口
/// 1. 提前做好方法的交换
class VisualStatistics: NSObject {
    @objc static func addAutoTrackSwizzles() {
        UIViewController.swizzleOnce()
        UIView.swizzleOnce()
    }
}
