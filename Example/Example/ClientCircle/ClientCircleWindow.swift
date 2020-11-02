//
//  ClientCircleWindow.swift
//  TestCircle
//
//  Created by rjb on 2020/10/29.
//

import UIKit

class ClientCircleWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let alertValue = UIWindow.Level.alert.rawValue
        self.windowLevel = UIWindow.Level(rawValue: alertValue + 100)
        self.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3)
        self.isHidden = false
        self.rootViewController = ClientCircleRootViewController()
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
        } else {
            return view
        }
    }
}
