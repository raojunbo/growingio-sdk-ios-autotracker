//
// ClientCircleRootViewController2.swift
// Example
//
//  Created by rjb on 2020/11/3.

import UIKit

class CircleRootViewController: UIViewController {
    /// 选中器
    lazy var circleSelectView:CircleSelectView = {
        let rect = UIScreen.main.bounds
        let view = CircleSelectView(frame: CGRect(x: rect.width/2.0, y: rect.height/2.0, width: 60, height: 60))
        return view
    }()
    
    lazy var panGer:UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(panGerClick))
    }()
    
    /// 被选中覆盖层
    lazy var coverView:CircleSelectCoverView = {
        return CircleSelectCoverView(frame:CGRect.zero)
    }()
    
    /// 被选中的视图
    var fitView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        self.view.addSubview(circleSelectView)
        self.view.addGestureRecognizer(panGer)
    }
    
    @objc func panGerClick(gesture:UIPanGestureRecognizer) {
        let translatePoint = gesture.translation(in: self.view)
        circleSelectView.center = CGPoint(x: circleSelectView.center.x + translatePoint.x, y: circleSelectView.center.y + translatePoint.y)
        gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        let centerPoint = circleSelectView.center
        if gesture.state == UIGestureRecognizer.State.ended {
            let infoDict = nodeInfo(centerPoint)
          
            if let  infoNSDict = infoDict as NSDictionary? , let infoStr = infoNSDict.growingHelper_jsonString(){
               
                print("选中信息:\(infoStr)")
            }
           
            
        } else if gesture.state == UIGestureRecognizer.State.changed {
            fitView?.layer.borderWidth = 0
            fitView = selectedNode(centerPoint)
        }
    }
    
    @discardableResult
    func selectedNode(_ point:CGPoint) -> UIView? {
        let keyWindow = UIApplication.shared.keyWindow
        let event:UIEvent = UIEvent()
        let fitView = keyWindow?.mj_hitTest(point, with: event)
        
        coverView.removeFromSuperview()
        coverView.frame = fitView?.bounds ?? CGRect.zero
        fitView?.addSubview(coverView)
        
       return fitView
    }
    
    @discardableResult
    func nodeInfo(_ point:CGPoint) -> [String:Any]? {
        let fitView = selectedNode(point)
        guard let tmpFitView = fitView else {
            return nil
        }
        //获取节点
        let keyPath = GrowingNodeHelper.xPath(for: tmpFitView)
        let keyIndex = tmpFitView.growingNodeKeyIndex
        let dict = dictFromNode(aNode: tmpFitView, pageData: [:], keyIndex: keyIndex ?? 0, xPath: keyPath, isContainer: false)
        return dict
    }
    
    //页面信息的获取
    func dictFromPage(aNode:GrowingNode?,xPath:String?) -> [String:Any] {
        var dict = [String:Any]()
        let frame = aNode?.growingNodeFrame() //获取节点的frame
        if let frame = frame,!frame.equalTo(CGRect.zero) {//有值并且不是zero
            dict["left"] = frame.origin.x
            dict["top"] = frame.origin.y
            dict["width"] = frame.size.width
            dict["height"] = frame.size.height
        }
        
        dict["path"] = xPath
        let vc = aNode as? UIViewController
        if let vc = vc,let title = vc.title {
            dict["title"] = title
        }
        
        dict["isIgnored"] = vc?.growingPageHelper_pageDidIgnore()
        return dict
    }

    //普通节点信息的获取
    func dictFromNode(aNode:GrowingNode?,pageData:[String:Any],keyIndex:Int,xPath:String,isContainer:Bool) -> [String:Any]? {
        //节点不存在
        guard let aNode = aNode else {
            return nil
        }
        //节点无法交互
        guard !aNode.growingNodeUserInteraction() else {
            return nil
        }
        
        var dict = [String:Any]()
        //合并信息
        dict.merge(pageData) { (one, two) -> Any in
            return one
        }
        //获取节点内容
        var v:String? = aNode.growingNodeContent()
        if v == nil  {
            v = ""
        }else{
            v = v?.growingHelper_safeSubString(withLength: 50)
        }
        
        dict["content"] = v
        

        var nodeType = "TEXT"
        if aNode.isKind(of: UITextField.self) || aNode.isKind(of: UISearchBar.self) || aNode.isKind(of: UITextView.self){
            nodeType = "INPUT"
        } else if aNode.isKind(of: UICollectionViewCell.self) || aNode.isKind(of: UITableViewCell.self){
            nodeType = "LIST"
        } else if aNode.growingNodeUserInteraction() {
            nodeType = "BUTTON"
        }
        //为node 元素添加层级关系
        if aNode.isKind(of: UIView.self) {
//            nodeZLevel = Float(aNode.growingNodeWindow()?.windowLevel.rawValue ?? 0)
//            zLevel = 0
//            self.getElementLevelInWindow(aNode:aNode, superView: aNode.growingNodeWindow())
//            dict["zLevel"] = self.zLevel
        }
        
        if keyIndex >= 0 {
            dict["index"] = String(keyIndex)
        }
        dict["xpath"] = xPath
        
        let frame = aNode.growingNodeFrame()
        if !frame.equalTo(CGRect.zero) {
            dict["left"] = frame.origin.x
            dict["top"] = frame.origin.y
            dict["width"] = frame.width
            dict["height"] = frame.height
        }
        dict["nodeType"] = nodeType
        dict["isContainer"] = isContainer
        return dict
    }
    
//    func getElementLevelInWindow(aNode:GrowingNode?, superView:UIView?) {
//        guard let aNode = aNode else {
//            return
//        }
//        guard let superView = superView else {
//            return
//        }
//        for (index,_) in superView.subviews.enumerated() {
//            self.nodeZLevel = self.nodeZLevel + 1
//            if superView.subviews[index] === aNode {
//                self.zLevel = self.nodeZLevel
//            }else {
//                getElementLevelInWindow(aNode: aNode, superView: superView.subviews[index])
//            }
//        }
//    }
}
