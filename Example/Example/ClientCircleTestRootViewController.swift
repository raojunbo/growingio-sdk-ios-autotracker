//
//  MJCircleScreenViewViewController.swift
//  TestCircle
//
//  Created by rjb on 2020/10/29.
//

import UIKit

class ClientCircleTestRootViewController: UIViewController {
    lazy var figureView:CircleSelectView = {
        let rect = UIScreen.main.bounds
        let view = CircleSelectView(frame: CGRect(x: rect.width/2.0, y: rect.height/2.0, width: 60, height: 60))
        view.backgroundColor = UIColor(red: 220, green: 50, blue: 35, alpha: 1)
        return view
    }()
    
    
    lazy var panGer:UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGerClick))
        return pan
    }()
    
    var nodeZLevel:Float = 0
    var zLevel:Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        self.view.addSubview(figureView)
        self.view.addGestureRecognizer(panGer)
    }
    
    @objc func panGerClick(gesture:UIPanGestureRecognizer) {
        let translatePoint = gesture.translation(in: self.view)
        figureView.center = CGPoint(x: figureView.center.x + translatePoint.x, y: figureView.center.y + translatePoint.y)
        gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        
        if gesture.state == UIGestureRecognizer.State.ended {
            let centerPoint = figureView.center
            checkWillSelect(point: centerPoint)
        } else if gesture.state == UIGestureRecognizer.State.changed {
            let centerPoint = figureView.center
            checkWillSelect(point: centerPoint)
        }
    }
    
    func checkWillSelect(point:CGPoint) {
        let keyWindow = UIApplication.shared.keyWindow
        let event:UIEvent = UIEvent()
        let fitView = keyWindow?.mj_hitTest(point, with: event)
        
        guard let tmpFitView = fitView else {
            return
        }
        let keyIndex = fitView?.growingNodeKeyIndex
        
        let keyPath = GrowingNodeHelper.xPath(for: tmpFitView)
        
        let dict = dictFromNode(aNode: fitView, pageData: [:], keyIndex: keyIndex ?? 0, xPath: keyPath, isContainer: false)
        fitView?.layer.borderWidth = 2
        fitView?.layer.borderColor = UIColor.green.cgColor
        print(dict)
    }
    
   //遍历获取所有节点树
    func fillAllViews(completion:(NSDictionary)->Void)   {
        //根据页面管理器，找到根VC节点
        //根据根VC节点生成节点管理器
        let rootVC = GrowingPageManager.sharedInstance()?.rootViewController()
        let manager = GrowingNodeManager(nodeAndParent: rootVC) { (node) -> Bool in
            guard let node = node else {
                return false
            }
            if node.growingNodeDonotTrack() || node.growingNodeDonotCircle(){
                return false
            }
            return true
        }
        
        //获取当前的vc的页面信息
        var modifiedPageDataDict:[String:Any] = [:]
        modifiedPageDataDict["page"] = GrowingPageManager.sharedInstance()?.currentViewController()?.growingPageName() ?? ""
        modifiedPageDataDict["domain"] = GrowingDeviceInfo.current()?.bundleID
        
        
        var pages = [Any]() //页面存储
        var elements:[GrowingNode] = [] //元素
        
        //遍历节点
        manager?.enumerateChildren({ (aNode, context) in
            guard let aNode = aNode else {
                return
            }
            //如果节点是圈选窗口本省
            if aNode.isKind(of: CircleWindow.self) {
                context?.skipThisChilds()
                return
            }
            
            if aNode.isKind(of: UIViewController.self) {
                //若果节点是vc
                let current = aNode as? UIViewController
                var page = current?.growingPageHelper_getPageObject()
                if  page == nil {
                    GrowingPageManager.sharedInstance()?.createdViewControllerPage(current)
                    page = current?.growingPageHelper_getPageObject()
                }
                //获取该vc的基本信息
                let dict:[String:Any] = self.dictFromPage(aNode: aNode, xPath: page?.path)
                if dict.count > 0 {
                    pages.append(dict)
                }
                
            } else {
                //若果节点不是vc
                //var dict =
            }
        })
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
            nodeZLevel = Float(aNode.growingNodeWindow()?.windowLevel.rawValue ?? 0)
            zLevel = 0
            self.getElementLevelInWindow(aNode:aNode, superView: aNode.growingNodeWindow())
            dict["zLevel"] = self.zLevel
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
    
    func getElementLevelInWindow(aNode:GrowingNode?, superView:UIView?) {
        guard let aNode = aNode else {
            return
        }
        guard let superView = superView else {
            return
        }
        for (index,_) in superView.subviews.enumerated() {
            self.nodeZLevel = self.nodeZLevel + 1
            if superView.subviews[index] === aNode {
                self.zLevel = self.nodeZLevel
            }else {
                getElementLevelInWindow(aNode: aNode, superView: superView.subviews[index])
            }
        }
    }
    
}
