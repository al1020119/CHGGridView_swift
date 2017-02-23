//
//  ViewViewController.swift
//  SwiftTest
//
//  Created by Hogan on 2017/2/23.
//  Copyright © 2017年 Hogan. All rights reserved.
//

import UIKit

class ViewViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.restoresFocusAfterTransition = true
        // Do any additional setup after loading the view.
        self.title = "CHGGridView Demo"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:UITableViewCell = UITableViewCell()
        let array:NSArray = ["CHGGridView基础控件Demo",
                             "CHGTabPageView控件展示Demo",
                             "菜单、广告、首页导航展示"]
        cell.textLabel?.text = array.object(at: indexPath.row) as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var vc:UIViewController!
        
        if indexPath.row == 0 {
            vc = MyViewController(nibName: "MyViewController", bundle: nil)
        } else if indexPath.row == 1 {
            vc = CHGTabPageDemoViewController(nibName: "CHGTabPageDemoViewController", bundle: nil)
        } else {
            vc = CHGGridMenuViewController(nibName: "CHGGridMenuViewController", bundle: nil)
        }
    
        let array:NSArray = ["CHGGridView基础控件Demo",
                             "CHGTabPageView控件展示Demo",
                             "菜单、广告、首页导航展示"]
        vc.title = array.object(at: indexPath.row) as? String
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
