//
//  ViewController.swift
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/8.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var zyThumbnailTableVC: ZYThumbnailTableViewController!
    
    var dataList = NSArray()
    
    let cellHeight: CGFloat = 100.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNav()
        configureZYTableView()
    }
    
    func configureNav() {
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.title = "welcome !"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 77/255.0, green: 105/255.0, blue: 121/255.0, alpha: 1.0)
    }
    
    func configureZYTableView() {
        zyThumbnailTableVC = ZYThumbnailTableViewController()
        zyThumbnailTableVC.cellReuseId = "zythumbnailCell"
        zyThumbnailTableVC.cellHeight = 100.0
        
        //因为是push过去的关系,数据源交给tableviewcontroller，更新数据源也交给他吧
        zyThumbnailTableVC.configureTableViewCellBlock = {
            //这里的名字是自定义的,看能不能把重用id也动态？
            let cell = NSBundle.mainBundle().loadNibNamed("ZYThumbnailTableViewCell", owner: nil, options: nil).first as? ZYThumbnailTableViewCell
            //configure cell
            cell?.updateCell()
            return cell
        }
        
        zyThumbnailTableVC.spreadCellAnimationBlock =  {
            let cell = $0 as? ZYThumbnailTableViewCell
            cell?.contentLabel.numberOfLines = 0
            print("更新了行数")
        }
        
        zyThumbnailTableVC.createTopExpansionViewBlock = {
            return TopView.createView()!
        }
        
        zyThumbnailTableVC.createBottomExpansionViewBlock = {
            return BottomView.createView()!
        }
    }
    
    @IBAction func clickEnterButton(sender: UIButton) {
        self.navigationController?.pushViewController(zyThumbnailTableVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
