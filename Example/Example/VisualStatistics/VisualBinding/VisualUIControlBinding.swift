//
// VisualUIControlBinding.swift
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

/// UIControl类型的点击事件的绑定处理类
class VisualUIControlBinding: VisualCodelessBinding {
    let controlEvent: UIControl.Event
    let verifyEvent: UIControl.Event
    var verified: NSHashTable<UIControl>
    var appliedTo: NSHashTable<UIControl>
    
    init(eventName: String, path: String, controlEvent:UIControl.Event, verifyEvent:UIControl.Event) {
        self.controlEvent = controlEvent
        self.verifyEvent = verifyEvent
        //NSHashTableObjectPointerPersonality 直接使用指针进行hash与equal
        self.verified = NSHashTable(options: [NSHashTableWeakMemory, NSHashTableObjectPointerPersonality])
        self.appliedTo = NSHashTable(options: [NSHashTableWeakMemory, NSHashTableObjectPointerPersonality])
        super.init(eventName: eventName, path: path)
        if #available(iOS 12.0, *) {
            self.swizzleClass = path.range(of: "UITextField") != nil ? UITextField.self : UIControl.self
        }
        else {
            self.swizzleClass = UIControl.self
        }
    }
    
    /// 通过绑定的json数据初始化绑定
    /// - Parameter object: 返回构建的绑定对象
    convenience init?(object:[String:Any]) {
        guard let path = object["path"] as? String,path.count >= 1 else {
            return nil
        }
        guard let eventName = object["event_name"] as? String, eventName.count >= 1 else {
            return nil
        }
        guard let controlEvent = object["control_event"] as? UInt, controlEvent & UIControl.Event.allEvents.rawValue != 0 else {
            return nil
        }
        
        /// 最终需要验证的事件类型
        var finalVerifyEvent: UIControl.Event
        if let verifyEvent = object["control_event"] as? UInt, verifyEvent & UIControl.Event.allEvents.rawValue != 0 {
            finalVerifyEvent = UIControl.Event(rawValue: verifyEvent)
        } else if controlEvent & UIControl.Event.allTouchEvents.rawValue != 0 {
            finalVerifyEvent = UIControl.Event.touchDown
        } else if controlEvent & UIControl.Event.allEditingEvents.rawValue != 0 {
            finalVerifyEvent = UIControl.Event.editingDidBegin
        } else {
            return nil
        }
        
        self.init(eventName: eventName,
                  path: path,
                  controlEvent: UIControl.Event(rawValue: controlEvent),
                  verifyEvent: finalVerifyEvent)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? VisualUIControlBinding else {
            return false
        }

        if object === self {
            return true
        } else {
            return super.isEqual(object) && self.controlEvent == object.controlEvent && self.verifyEvent == object.verifyEvent
        }
    }

    override var hash: Int {
        return super.hash ^ Int(self.controlEvent.rawValue) ^ Int(self.verifyEvent.rawValue)
    }

    override var description: String {
        return "UIControl Codeless Binding: \(eventName) for \(path)"
    }

    func resetUIControlStore() {
        verified = NSHashTable(options: [NSHashTableWeakMemory, NSHashTableObjectPointerPersonality])
        appliedTo = NSHashTable(options: [NSHashTableWeakMemory, NSHashTableObjectPointerPersonality])
    }
    
    override func execute() {
        if !self.running {
            let executeBlock = { (view: AnyObject?, command: Selector, param1: AnyObject?, param2: AnyObject?) in
                //当一个视图发生变化 或者 被加入父视图。执行这个绑定工作
                if let root = UIApplication.shared.keyWindow?.rootViewController {
                    //如果已经被绑定了。
                    if let view = view as? UIControl, self.appliedTo.contains(view) {
                        //如果路径没有被选择（说明：因为这个Block是在这个view被添加到父视图，或者layoutsubviews才执行）
                        if !self.path.isSelected(leaf: view, from: root, isFuzzy: true) {
                            self.stopOn(view: view)
                            self.appliedTo.remove(view)
                        }
                    } else {
                        var objects: [UIControl]
                        // select targets based off path
                        // 基于路径去查找Views
                        if let view = view as? UIControl {
                            if self.path.isSelected(leaf: view, from: root, isFuzzy: true) {
                                objects = [view]
                            } else {
                                objects = []
                            }
                        } else if let objectsSelectFrom =  self.path.selectFrom(root: root, evaluateFinalPredicate: false) as? [UIControl] {
                            //(这是什么情况？)
                            objects = objectsSelectFrom
                        } else {
                            objects = []
                        }
                        
                        /// 找到的objects 执行操作
                        for control in objects {
                            if self.verifyEvent != UIControl.Event(rawValue:0) && self.verifyEvent != self.controlEvent {
                                control.addTarget(self, action: #selector(self.preVerify(sender:event:)), for: self.verifyEvent)
                            }
                            control.addTarget(self, action: #selector(self.execute(sender:event:)), for: self.controlEvent)
                            self.appliedTo.add(control)
                        }
                    }
                }
            }
            // 以下实际上就是在UIView被添加到父View的时候，给view绑定一个block
            // Execute once in case the view to be tracked is already on the screen
            executeBlock(nil, #function, nil, nil)
            
            VisualSwizzler.swizzleSelector(NSSelectorFromString("didMoveToWindow"),
                                     withSelector: #selector(UIView.newDidMoveToWindow),
                                     for: swizzleClass,
                                     name: name,
                                     block: executeBlock)
            VisualSwizzler.swizzleSelector(NSSelectorFromString("didMoveToSuperview"),
                                     withSelector: #selector(UIView.newDidMoveToSuperview),
                                     for: swizzleClass,
                                     name: name,
                                     block: executeBlock)
            running = true
        }
    }
    
    func stopOn(view: UIControl) {
        if verifyEvent != UIControl.Event(rawValue: 0) && verifyEvent != controlEvent {
            view.removeTarget(self, action: #selector(self.preVerify(sender:event:)), for: verifyEvent)
        }
        view.removeTarget(self, action: #selector(self.execute(sender:event:)), for: controlEvent)
    }
    
    @objc func preVerify(sender: UIControl, event: UIEvent) {
        if verifyControlMatchesPath(sender) {
            verified.add(sender)
        } else {
            verified.remove(sender)
        }
    }
    
    func verifyControlMatchesPath(_ control: AnyObject) -> Bool {
        if let root = UIApplication.shared.keyWindow?.rootViewController {
            return path.isSelected(leaf: control, from: root)
        }
        return false
    }

    
    @objc func execute(sender: UIControl, event: UIEvent) {
        var shouldTrack = false
        if verifyEvent != UIControl.Event(rawValue: 0) && verifyEvent != controlEvent {
            shouldTrack = verified.contains(sender)
        } else {
            shouldTrack = verifyControlMatchesPath(sender)
        }
        if shouldTrack {
//            self.track(event: eventName, properties: [:])
        }
    }
    
}

extension UIView {
    @objc func callOriginalFunctionAndSwizzledBlocks(originalSelector: Selector) {
        //从originalSelector取出swizzle，并取出了block
        if let originalMethod = class_getInstanceMethod(type(of: self), originalSelector),
            let swizzle = VisualSwizzler.swizzles[originalMethod] {
            
            typealias MyCFunction = @convention(c) (AnyObject, Selector) -> Void
            let curriedImplementation = unsafeBitCast(swizzle.originalMethod, to: MyCFunction.self)
            curriedImplementation(self, originalSelector)
            //执行一个swizzle里的block
            for (_, block) in swizzle.blocks {
                block(self, swizzle.selector, nil, nil)
            }
        }
    }

    @objc func newDidMoveToWindow() {
        
        /// 移动到新的Windown,执行绑定的工作
        let originalSelector = NSSelectorFromString("didMoveToWindow")
        callOriginalFunctionAndSwizzledBlocks(originalSelector: originalSelector)
    }

    @objc func newDidMoveToSuperview() {
        
        /// 移除window时解除绑定
        let originalSelector = NSSelectorFromString("didMoveToSuperview")
        callOriginalFunctionAndSwizzledBlocks(originalSelector: originalSelector)
    }

    @objc func newLayoutSubviews() {
        //视图的layoutSubViews变化时，也重新绑定
        let originalSelector = NSSelectorFromString("layoutSubviews")
        callOriginalFunctionAndSwizzledBlocks(originalSelector: originalSelector)
    }
}
