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
        zyThumbnailTableVC.cellReuseId = "DIYTableViewCell"
        zyThumbnailTableVC.cellHeight = 100.0
        
        //create dataSource
        let dataList = NSMutableArray()
        var tempDict: [String : String]
        for index in  0...9 {
            tempDict = ["name":"hava a nice day \(index)",
                        "desc":"sub title and sub title \(index)",
                        "time":"timestamp\(index)",
                        "content":"Pro tip: (\(index)) updating your profile with your name, location, and a profile picture helps other GitHub users get to know you.\n-\(index)-\nA Button spread its sub path buttons like the flower or sickle(two spread mode) if you click it, once again, close.And you can also change the SpreadPositionMode between FixedMode & TouchBorderMode， while one like the marbleBall fixed on the wall, another one like the AssistiveTouch is iphone"]
            dataList.addObject(tempDict)
        }
        zyThumbnailTableVC.dataList = NSArray(array: dataList)
        
        //因为是push过去的关系,数据源交给tableviewcontroller，更新数据源也交给他吧
        zyThumbnailTableVC.configureTableViewCellBlock = {
            let cell = DIYTableViewCell.createCell()
            return cell
        }
        
        zyThumbnailTableVC.updateTableViewCellBlock =  { (cell: UITableViewCell, indexPath: NSIndexPath) -> Void in
            let myCell = cell as? DIYTableViewCell
            guard let dataDict = dataList[indexPath.row] as? [String : String] else {
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
    
}
