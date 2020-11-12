//
// VisualSwizzler.swift
// Example
//
//  Created by rjb on 2020/11/11.
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

class VisualSwizzler {
    static var swizzles = [Method: VisualSwizzle]()

    class func printSwizzles() {
        for (_, swizzle) in swizzles {
//            Logger.debug(message: "\(swizzle)")
            print("message:\(swizzle)")
        }
    }

    class func getSwizzle(for method: Method) -> VisualSwizzle? {
        return swizzles[method]
    }

    class func removeSwizzle(for method: Method) {
        swizzles.removeValue(forKey: method)
    }

    class func setSwizzle(_ swizzle: VisualSwizzle, for method: Method) {
        swizzles[method] = swizzle
    }

    class func swizzleSelector(_ originalSelector: Selector,
                               withSelector newSelector: Selector,
                               for aClass: AnyClass,
                               name: String,
                               block: @escaping ((_ view: AnyObject?,
                                                  _ command: Selector,
                                                  _ param1: AnyObject?,
                                                  _ param2: AnyObject?) -> Void)) {

        if let originalMethod = class_getInstanceMethod(aClass, originalSelector),
            let swizzledMethod = class_getInstanceMethod(aClass, newSelector) {

            let swizzledMethodImplementation = method_getImplementation(swizzledMethod)
            let originalMethodImplementation = method_getImplementation(originalMethod)

            var swizzle = getSwizzle(for: originalMethod)
            if swizzle == nil {
                swizzle = VisualSwizzle(block: block,
                                  name: name,
                                  aClass: aClass,
                                  selector: originalSelector,
                                  originalMethod: originalMethodImplementation)
                setSwizzle(swizzle!, for: originalMethod)
            } else {
                swizzle?.blocks[name] = block
            }

            let didAddMethod = class_addMethod(aClass,
                                               originalSelector,
                                               swizzledMethodImplementation,
                                               method_getTypeEncoding(swizzledMethod))
            if didAddMethod {
                setSwizzle(swizzle!, for: class_getInstanceMethod(aClass, originalSelector)!)
            } else {
                method_setImplementation(originalMethod, swizzledMethodImplementation)
            }
        } else {
//            Logger.error(message: "Swizzling error: Cannot find method for "
//                + "\(NSStringFromSelector(originalSelector)) on \(NSStringFromClass(aClass))")
        }
    }

    class func unswizzleSelector(_ selector: Selector, aClass: AnyClass, name: String? = nil) {
        if let method = class_getInstanceMethod(aClass, selector),
            let swizzle = getSwizzle(for: method) {
            if let name = name {
                swizzle.blocks.removeValue(forKey: name)
            }

            if name == nil || swizzle.blocks.count < 1 {
                method_setImplementation(method, swizzle.originalMethod)
                removeSwizzle(for: method)
            }
        }
    }

}

class VisualSwizzle: CustomStringConvertible {
    let aClass: AnyClass
    let selector: Selector
    let originalMethod: IMP
    var blocks = [String: ((view: AnyObject?, command: Selector, param1: AnyObject?, param2: AnyObject?) -> Void)]()
    //将不同的name的
    init(block: @escaping ((_ view: AnyObject?, _ command: Selector, _ param1: AnyObject?, _ param2: AnyObject?) -> Void),
         name: String,
         aClass: AnyClass,
         selector: Selector,
         originalMethod: IMP) {
        self.aClass = aClass
        self.selector = selector
        self.originalMethod = originalMethod
        self.blocks[name] = block
    }

    var description: String {
        var retValue = "Swizzle on \(NSStringFromClass(type(of: self)))::\(NSStringFromSelector(selector)) ["
        for (key, value) in blocks {
            retValue += "\t\(key) : \(String(describing: value))\n"
        }
        return retValue + "]"
    }


}
