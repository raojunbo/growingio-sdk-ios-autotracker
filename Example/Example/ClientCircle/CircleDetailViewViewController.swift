//
// CircleDetailViewViewController.swift
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
private let kGrayColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)

class CircleDetailViewViewController: UIViewController {
    var nodeInfo:CircleNodeModel?
    let nameTipLabel = UILabel(frame: CGRect.zero)
    let nameField = UITextField(frame: CGRect.zero)
    
    let keyLabel = UILabel(frame: CGRect.zero)
    let keyField = UITextField(frame: CGRect.zero)
    
    let snapshotView = UIImageView(frame: CGRect.zero)

    let pageNameLabel = UILabel(frame: CGRect.zero)
    let xpathLabel = UILabel(frame: CGRect.zero)
    let contentLabel = UILabel(frame: CGRect.zero)
    
    let saveButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "定义view"
        self.view.backgroundColor = UIColor.white
        layoutUI()
    }
    
    @objc func save()  {
        //生成需要上传的json数据
        //卖点名称
        //event_type:点击事件
        //path
        //event_name
        //screen_url
    }
    
    func layoutUI()  {
        let navHeight = navigationController?.navigationBar.frame.size.height
        
        nameTipLabel.text = "名称"
        nameTipLabel.frame = CGRect(x: kLeftMargin, y: kTopMargin + navHeight!, width: 40, height: 35)
        
        nameField.placeholder = "埋点名称"
        nameField.layer.borderWidth = 1
        nameField.layer.borderColor = kGrayColor.cgColor
        nameField.frame = CGRect(x: nameTipLabel.right + kLeftMargin, y: nameTipLabel.top, width: 250, height: 35)
        
        keyLabel.text = "KEY"
        keyLabel.frame = CGRect(x: kLeftMargin, y: nameTipLabel.bottom + kTopMargin, width: 40, height: 35)

        keyField.placeholder = "埋点key"
        keyField.layer.borderWidth = 1
        keyField.layer.borderColor = kGrayColor.cgColor
        keyField.frame = CGRect(x: keyLabel.right + kLeftMargin, y: keyLabel.top, width: 250, height: 40)
        
        snapshotView.frame = CGRect(x: kLeftMargin, y: keyField.bottom + kTopMargin, width: 100, height: 100)
        snapshotView.backgroundColor = kGrayColor
        snapshotView.image = nodeInfo?.snapshot
        snapshotView.centerX = view.centerX

        pageNameLabel.frame = CGRect(x: kLeftMargin, y: snapshotView.bottom , width: UIScreen.main.bounds.width - kLeftMargin * 2, height: 40)
        pageNameLabel.font = UIFont.systemFont(ofSize: 12)
        pageNameLabel.text = nodeInfo?.belongToVC
        
        xpathLabel.frame = CGRect(x: kLeftMargin, y: pageNameLabel.bottom + kTopMargin, width: UIScreen.main.bounds.width - kLeftMargin * 2, height: 0)
        xpathLabel.numberOfLines = 0
        xpathLabel.font = UIFont.systemFont(ofSize: 12)
        xpathLabel.text = nodeInfo?.xpath
        xpathLabel.height = xpathLabel.requiredHeight

        
        contentLabel.frame = CGRect(x: kLeftMargin, y: xpathLabel.bottom , width: UIScreen.main.bounds.width - kLeftMargin * 2, height: 40)
        contentLabel.text = nodeInfo?.content
        contentLabel.font = UIFont.systemFont(ofSize: 12)
        
        saveButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        saveButton.centerX = view.centerX
        saveButton.top = contentLabel.bottom + kTopMargin
        saveButton.setTitle("保存", for: .normal)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        saveButton.backgroundColor = UIColor(red: 42/255.0, green: 144/255.0, blue: 220/255.0, alpha: 1)
        
        self.view.addSubview(nameTipLabel)
        self.view.addSubview(nameField)
        
        self.view.addSubview(keyLabel)
        self.view.addSubview(keyField)
        
        self.view.addSubview(snapshotView)
        self.view.addSubview(pageNameLabel)
        
        self.view.addSubview(xpathLabel)
        self.view.addSubview(contentLabel)
        
        self.view.addSubview(saveButton)
    }

}
