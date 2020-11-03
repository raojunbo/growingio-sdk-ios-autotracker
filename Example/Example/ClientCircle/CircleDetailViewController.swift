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
private let kDetailCellHeight:CGFloat = 220

class CircleDetailCell:UITableViewCell {
    let bgView:UIView = UIView.init(frame: CGRect.zero)
    let typeLabel:UILabel = UILabel.init(frame: CGRect.zero)
    let snapShotView:UIImageView = UIImageView.init(frame: CGRect.zero)
    let classNameLabel:UILabel = UILabel.init(frame: CGRect.zero)
    let contentLabel:UILabel = UILabel.init(frame: CGRect.zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createUI()
    }
    
    func createUI()  {
        let screenWidth = UIScreen.main.bounds.width
        bgView.frame = CGRect(x: kLeftMargin, y: kTopMargin, width: screenWidth - kLeftMargin * 2, height: kDetailCellHeight - kTopMargin * 2)
        let bgViewWidth =  screenWidth - kLeftMargin * 2
        bgView.backgroundColor = UIColor(red: 42/255.0, green: 153/255.0, blue: 213/255.0, alpha: 1)
        
        typeLabel.frame = CGRect(x: kLeftMargin, y: kTopMargin, width: 100, height: 40)
        typeLabel.text = "页面"
        
        snapShotView.frame = CGRect(x: bgViewWidth - kLeftMargin * 2 - 100, y: kTopMargin, width: 100, height: 100)
        snapShotView.backgroundColor = UIColor.red
        
        classNameLabel.frame = CGRect(x: kLeftMargin, y: typeLabel.frame.origin.y + typeLabel.frame.size.height + kTopMargin, width: 100, height: 40)
        classNameLabel.text = "类名"
        
        contentLabel.frame = CGRect(x: kLeftMargin, y: classNameLabel.frame.origin.y + classNameLabel.frame.size.height + kTopMargin, width: 100, height: 40)
        contentLabel.text = "内容"
      
        contentView.addSubview(bgView)
        bgView.addSubview(typeLabel)
        bgView.addSubview(snapShotView)
        bgView.addSubview(classNameLabel)
        bgView.addSubview(contentLabel)
        
        self.contentView.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CircleDetailViewController: UIViewController {
    var contentStr:String? = nil
    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height), style: UITableView.Style.plain)
        tableView.register(CircleDetailCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.delegate = self
        tableView.dataSource = self
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
