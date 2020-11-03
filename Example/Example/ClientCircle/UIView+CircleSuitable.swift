//
// UIView+Suitable.swift
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

extension UIView {
    
    class func findCircleSuitableView(point:CGPoint) -> UIView? {
        let keyWindow = UIApplication.shared.keyWindow
        let event:UIEvent = UIEvent()
        return keyWindow?.circleSuitableView(point: point, event: event)
    }
    
    private func circleSuitableView(point:CGPoint,event:UIEvent?) -> UIView? {
        //判定能否接收事件
        if self.isUserInteractionEnabled == false || self.isHidden == true || self.alpha <= 0.01 {
            return nil
        }
        
        //点击不在自己区域
        if !self.point(inside: point, with: event) {
            return nil
        }
        
        //寻找合适的子view(从后向前遍历)
        for childView in self.subviews.reversed() {
            //将当前的“点”的坐标系，转成子控件的坐标系；也就是点在子坐标系里的位置。
            let childP = self.convert(point, to: childView)
            //递归去寻找
            let fitView = childView.circleSuitableView(point: childP, event: event)
            if let fitView = fitView {
                return fitView
            }
        }
        //没有了子view，且自己满足条件
        return self
    }

}
