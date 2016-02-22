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
    
    override func viewWillAppear(animated: Bool) {
        let barItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
        self.navigationItem.backBarButtonItem = barItem
//        self.navigationItem.titleView?.tintColor = UIColor.blueColor()
//        self.navigationItem.titleView?.tintColor
//        self.navigationItem.titleView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNav()
        configureZYTableView()
    }
    
    func configureNav() {
        self.navigationController?.navigationBar.translucent = false
        /*
        //导航控制器背景色
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 77/255.0, green: 105/255.0, blue: 121/255.0, alpha: 1.0)
        //消除导航控制器底线
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        */
        let titleView = UILabel(frame: CGRectMake(0, 0, 200, 44))
        titleView.text = "ZYThumbnailTabelView"
        titleView.textAlignment = .Center
        titleView.font = UIFont.systemFontOfSize(20.0);
        //503f39
        titleView.textColor = UIColor(red: 63/255.0, green: 47/255.0, blue: 41/255.0, alpha: 1.0)
        self.navigationItem.titleView = titleView
    }
    
    func configureZYTableView() {
        zyThumbnailTableVC = ZYThumbnailTableViewController()
        zyThumbnailTableVC.cellReuseId = "DIYTableViewCell"
        zyThumbnailTableVC.cellHeight = 100.0
        
        dataList = createDataSource()
        zyThumbnailTableVC.dataList = dataList
        
        //因为是push过去的关系,数据源交给tableviewcontroller，更新数据源也交给他吧
        zyThumbnailTableVC.configureTableViewCellBlock = {
            let cell = DIYTableViewCell.createCell()
            return cell
        }
        
        zyThumbnailTableVC.updateTableViewCellBlock =  { (cell: UITableViewCell, indexPath: NSIndexPath) -> Void in
            let myCell = cell as? DIYTableViewCell
            guard let dataDict = self.dataList[indexPath.row] as? [String : String] else {
                print("ERROR: illegal tableview dataSource")
                return
            }
            myCell?.updateCell(dataDict)
        }
        
        zyThumbnailTableVC.spreadCellAnimationBlock =  {
            let cell = $0 as? DIYTableViewCell
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
    
    //Virtual DataSource
    func createDataSource() -> NSArray {
        let dataSource = NSMutableArray()
        let content = "The lesson of the story, I suggested, was that in some strange sense we are more whole when we are missing something. \n    The man who has everything is in some ways a poor man. \n    He will never know what it feels like to yearn, to hope, to nourish his soul with the dream of something better. \n    He will never know the experience of having someone who loves him give him something he has always wanted or never had."
        
        dataSource.addObject([
            "name" : "NURGIO",
            "desc" : "Beijing,Chaoyang District",
            "time" : "3 minute",
          "content": content,
            ])
        
        dataSource.addObject([
            "name" : "Cheers",
            "desc" : "Joined on Dec 18, 2014",
            "time" : "8 minute",
            "content": content,
            ])
        
        dataSource.addObject([
            "name" : "Adleys",
            "desc" : "The Technology Studio",
            "time" : "16 minute",
            "content": content,
            ])
        
        dataSource.addObject([
            "name" : "Coder_CYX",
            "desc" : "Joined on Mar 26, 2013",
            "time" : "21 minute",
            "content": content,
            ])
        
        dataSource.addObject([
            "name" : "Coleman",
            "desc" : "Zhejiang University of Technology",
            "time" : "28 minute",
            "content": content,
            ])
        
        dataSource.addObject([
            "name" : "Moguilay",
            "desc" : "zbien.com",
            "time" : "33 minute",
            "content": content,
            ])
        
        dataSource.addObject([
            "name" : "Dikey",
            "desc" : "Pluto at the moment",
            "time" : "35 minute",
            "content": content,
            ])
        
        dataSource.addObject([
            "name" : "fmricky",
            "desc" : "Waterloo, ON",
            "time" : "42 minute",
            "content": content,
            ])
        
        dataSource.addObject([
            "name" : "Robert Waggott",
            "desc" : "Beijing chaoyang",
            "time" : "46 minute",
            "content": content,
            ])
        
        return NSArray(array: dataSource)
    }
    
}
