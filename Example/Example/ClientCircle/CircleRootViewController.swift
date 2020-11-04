//
// ClientCircleRootViewController2.swift
// Example
//
//  Created by rjb on 2020/11/3.

import UIKit
import SwiftyJSON

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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
            let circleInfoModel = nodeAndVCInfo(centerPoint)
            pushToDetailVC(circleInfo: circleInfoModel)
        } else if gesture.state == UIGestureRecognizer.State.changed {
            fitView = selectedNode(centerPoint,hadCover: true)
        }
    }
    
    func pushToDetailVC(circleInfo:CircleInfoModel?) {
        let detailVC = CircleDetailViewController()
        detailVC.circleInfo = circleInfo
        let nav = UINavigationController(rootViewController: detailVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    @discardableResult
    func selectedNode(_ point:CGPoint, hadCover:Bool) -> UIView? {
        let fitView = UIView.findCircleSuitableView(point: point)
        coverView.removeFromSuperview()
        coverView.frame = fitView?.bounds ?? CGRect.zero
        if hadCover {
            fitView?.addSubview(coverView)
        }
        return fitView
    }
    
    @discardableResult
    func nodeAndVCInfo(_ point:CGPoint) -> CircleInfoModel? {
        let fitView = selectedNode(point,hadCover: false)
        guard let tmpFitView = fitView else {
            return nil
        }
        
        //获取view节点信息
        var viewNodeModel = nodeViewInfo(tmpFitView)
        let viewShot = fitView?.growingNodeScreenShot(withScale: UIScreen.main.scale)
        viewNodeModel?.snapshot = viewShot
        
        //获取cell节点信息
        let cell = UIView.checkParentHadCell(fitView: tmpFitView)
        var cellNodeModel:CircleNodeModel?
        if let tmpCell = cell  {
            cellNodeModel = nodeViewInfo(tmpCell)
            cellNodeModel?.snapshot =  tmpCell.growingNodeScreenShot(withScale: UIScreen.main.scale)
        }
        
        //取vc节点信息
        var vcNodeModel = nodeVCInfo()
        let currentVC = GrowingPageManager.sharedInstance()?.currentViewController()
        let vcShot = currentVC?.growingNodeScreenShot(withScale: UIScreen.main.scale)
        vcNodeModel?.snapshot = vcShot
        
        var circleInfoModel = CircleInfoModel(JSON())
        circleInfoModel.viewInfo = viewNodeModel
        circleInfoModel.vcInfo = vcNodeModel
        circleInfoModel.cellInfo = cellNodeModel
        return circleInfoModel
    }
    
    func nodeViewInfo(_ nodeView:GrowingNode) -> CircleNodeModel? {
        let keyPath = GrowingNodeHelper.xPath(for: nodeView)
        let keyIndex = nodeView.growingNodeKeyIndex
        let viewInfoDict = dictFromNode(aNode: nodeView, keyIndex: keyIndex, xPath: keyPath, isContainer: false)
        guard let tmpviewInfoDict = viewInfoDict else {
            return nil
        }
        return  CircleNodeModel(JSON(tmpviewInfoDict))
    }
    
    func nodeVCInfo() -> CircleNodeModel? {
        let currentVC = GrowingPageManager.sharedInstance()?.currentViewController()
        var page = currentVC?.growingPageHelper_getPageObject()
        if  page == nil {
            GrowingPageManager.sharedInstance()?.createdViewControllerPage(currentVC)
            page = currentVC?.growingPageHelper_getPageObject()
        }
        guard let tmpCurrentVC = currentVC else {
            return nil
        }
        let pageDict = dictFromPage(aNode: tmpCurrentVC, xPath: page?.path)
        guard let tmpPageDict = pageDict else {
            return nil
        }
        return CircleNodeModel(JSON(tmpPageDict))
    }
    
    //页面信息的获取
    func dictFromPage(aNode:GrowingNode,xPath:String?) -> [String:Any]? {
        var dict = [String:Any]()
        let frame = aNode.growingNodeFrame()
        
        dict["left"] = frame.origin.x
        dict["top"] = frame.origin.y
        dict["width"] = frame.size.width
        dict["height"] = frame.size.height
        
        dict["xpath"] = xPath
        dict["className"] = "\(type(of: aNode))"
        dict["nodeName"] = aNode.growingNodeName()
        dict["content"] =  aNode.growingNodeContent()
        
        let vc = aNode as? UIViewController
        if let vc = vc,let title = vc.title {
            dict["title"] = title
        }
        
        dict["isIgnored"] = vc?.growingPageHelper_pageDidIgnore()
        return dict
    }
    
    //普通节点信息的获取
    func dictFromNode(aNode:GrowingNode,keyIndex:Int,xPath:String,isContainer:Bool) -> [String:Any]? {
        
        var dict = [String:Any]()
        
        //获取节点内容
        let content:String? = aNode.growingNodeContent()
        dict["content"] = content
        dict["className"] = "\(type(of: aNode))"
        dict["nodeName"] = aNode.growingNodeName()
        
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
        dict["left"] = frame.origin.x
        dict["top"] = frame.origin.y
        dict["width"] = frame.width
        dict["height"] = frame.height
        dict["nodeType"] = nodeType
        dict["isContainer"] = isContainer
        return dict
    }
}

