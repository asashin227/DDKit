//
//  ViewController.swift
//  DDKitDdemo
//
//  Created by Asakura Shinsuke on 2017/06/14.
//  Copyright © 2017年 Asakura Shinsuke. All rights reserved.
//

import UIKit
import DDKit

private extension Selector {
    static let didTapedNext =  #selector(ViewController.didTapedNext(sender: ))
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem.init(title: "next", style: .plain, target: self, action: .didTapedNext)
        self.navigationItem.rightBarButtonItem = button
        view.backgroundColor = .white
        let width = view.bounds.size.width - 20
        
        let field1 = DDTextField(frame: CGRect(x: 10, y: 100, width: width, height: 40))
        field1.text = "Hello DDKit!!"
        field1.borderStyle = .roundedRect
        field1.clearButtonMode = .whileEditing
        view.addSubview(field1)
        
        let field2 = DDTextField(frame: CGRect(x: 10, y: 160, width: width, height: 40))
        field2.borderStyle = .roundedRect
        field2.clearButtonMode = .whileEditing
        view.addSubview(field2)
        
        let textView = DDTextView(frame: CGRect(x: 10, y: 220, width: width, height: 100))
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        view.addSubview(textView)
    }
    
    func didTapedNext(sender: UIBarButtonItem) {
        navigationController?.pushViewController(ViewController(), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


