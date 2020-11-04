//
// CircleDetailViewController.swift
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


import UIKit

private let kTopMargin:CGFloat = 10.0
private let kLeftMargin:CGFloat = 10.0
private let kDetailCellHeight:CGFloat = 170

class CircleDetailCell:UITableViewCell {
    let bgView:UIView = UIView.init(frame: CGRect.zero)
    let typeLabel:UILabel = UILabel.init(frame: CGRect.zero)
    let snapShotView:UIImageView = UIImageView.init(frame: CGRect.zero)
    let classNameLabel:UILabel = UILabel.init(frame: CGRect.zero)
    let contentLabel:UILabel = UILabel.init(frame: CGRect.zero)
    var _dataModel:CircleNodeModel?
    var dataModel:CircleNodeModel? {
        get {
            return _dataModel
        }
        set {
            _dataModel = newValue
            refreshView()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.white
        createUI()
    }
    
    func createUI()  {
        snapShotView.contentMode = .scaleAspectFit
        contentView.addSubview(bgView)
        bgView.addSubview(typeLabel)
        bgView.addSubview(snapShotView)
        bgView.addSubview(classNameLabel)
        bgView.addSubview(contentLabel)
        
        let screenWidth = UIScreen.main.bounds.width
        let bgViewWidth =  screenWidth - kLeftMargin * 2

        bgView.frame = CGRect(x: kLeftMargin, y: kTopMargin, width: screenWidth - kLeftMargin * 2, height: kDetailCellHeight - kTopMargin * 2)
        bgView.layer.cornerRadius = 4
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = UIColor(red: 42/255.0, green: 153/255.0, blue: 213/255.0, alpha: 1)
        snapShotView.frame = CGRect(x: bgViewWidth - kLeftMargin * 2 - 100, y: kTopMargin, width: 100, height: kDetailCellHeight - kTopMargin * 2)
    }
    
    func refreshView()  {
       
        typeLabel.frame = CGRect(x: 0, y: 0, width: 250, height: 0)
        typeLabel.text = "页面"
        typeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        typeLabel.textColor = UIColor.white
        typeLabel.lineBreakMode = .byCharWrapping
        typeLabel.numberOfLines = 0
        typeLabel.frame = CGRect(x: kLeftMargin, y: kTopMargin, width: 250, height: typeLabel.requiredHeight)

        classNameLabel.frame = CGRect(x: 0, y: 0 , width: 250, height: 0)
        classNameLabel.text = "类名"
        classNameLabel.textColor = UIColor.white
        classNameLabel.font = UIFont.systemFont(ofSize: 14)
        classNameLabel.numberOfLines = 0
        classNameLabel.lineBreakMode = .byCharWrapping
        classNameLabel.frame = CGRect(x: kLeftMargin, y: typeLabel.frame.origin.y + typeLabel.frame.size.height + kTopMargin, width: 250, height:classNameLabel.requiredHeight)
        
        contentLabel.frame = CGRect(x: 0, y: 0, width: 250, height: 0)
        contentLabel.text = "内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容"
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor.white
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.frame = CGRect(x: kLeftMargin, y: classNameLabel.frame.origin.y + classNameLabel.frame.size.height + kTopMargin, width: 250, height: contentLabel.requiredHeight)
        
        typeLabel.text = dataModel?.nodeName
        classNameLabel.text = dataModel?.className
        contentLabel.text = dataModel?.content
        snapShotView.image = dataModel?.snapshot
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CircleDetailViewController: UIViewController {
    var circleInfo:CircleInfoModel? = nil
    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height), style: UITableView.Style.plain)
        tableView.register(CircleDetailCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor  = UIColor.white
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "第一步：选择内容"
        self.view.addSubview(tableView)
    }
}

extension CircleDetailViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        if let circleCell = cell as? CircleDetailCell {
            if indexPath.row == 0 {
                circleCell.dataModel = circleInfo?.vcInfo
            }else if indexPath.row == 1{
                circleCell.dataModel = circleInfo?.viewInfo
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kDetailCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("选中了\(indexPath.row)")
        let vc:UIViewController?
        if indexPath.row == 0 {
            vc = CircleDetailVCViewController()
        } else {
            vc = CircleDetailViewViewController()
        }
        if let toVC = vc {
            self.navigationController?.pushViewController(toVC, animated: true)
        }
    }
}
