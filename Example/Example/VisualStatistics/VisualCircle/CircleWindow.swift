//
//  CircleWindow.swift
//  TestCircle
//
//  Created by rjb on 2020/10/29.
//

import UIKit

class CircleWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let alertValue = UIWindow.Level.alert.rawValue
        self.windowLevel = UIWindow.Level(rawValue: alertValue + 100)
        self.backgroundColor = UIColor(red: 220/255.0, green: 50/255.0, blue: 35/255.0, alpha: 0.2)
        self.isHidden = false
        self.rootViewController = CircleRootViewController2()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        //事件是window本身，或者vc.view时，由其他人递归的去处理事件
        if view === self {
            return nil
        } else if view == self.rootViewController?.view {
            return nil
        }
//        else if view == self.rootVC.view {
//            return nil
//        }
        else {
            return view
        }
    }
}
