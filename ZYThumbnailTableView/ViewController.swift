//
//  ViewController.swift
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/8.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ZYThumbnailTableViewControllerDelegate, DiyTopViewDelegate {

    var zyThumbnailTableVC: ZYThumbnailTableViewController!
    var dataList = NSArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNav()
        configureZYTableView()
    }
    
    func configureNav() {
        self.navigationController?.navigationBar.translucent = false
        let titleView = UILabel(frame: CGRectMake(0, 0, 200, 44))
        titleView.text = "ZYThumbnailTabelView"
        titleView.textAlignment = .Center
        titleView.font = UIFont.systemFontOfSize(20.0);
        //503f39
        titleView.textColor = UIColor(red: 63/255.0, green: 47/255.0, blue: 41/255.0, alpha: 1.0)
        self.navigationItem.titleView = titleView
        
        let barItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
        self.navigationItem.backBarButtonItem = barItem
    }
    
    func configureZYTableView() {
        zyThumbnailTableVC = ZYThumbnailTableViewController()
        zyThumbnailTableVC.tableviewCellReuseId = "DIYTableViewCell"
        zyThumbnailTableVC.tableviewCellHeight = 100.0
        

        //--------insert your diy tableview cell
        zyThumbnailTableVC.configureTableViewCellBlock = {
            return DIYTableViewCell.createCell()
        }
        
        dataList = createDataSource()
        //--------configure your diy tableview cell datalist
        zyThumbnailTableVC.tableviewDataList = dataList
        
        //--------update your cell here
        zyThumbnailTableVC.updateTableViewCellBlock =  { [weak self](cell: UITableViewCell, indexPath: NSIndexPath) -> Void in
            let myCell = cell as? DIYTableViewCell
            guard let dataSource = self?.zyThumbnailTableVC.tableviewDataList[indexPath.row] as? Post else {
                print("ERROR: illegal tableview dataSource")
                return
            }
            myCell?.updateCell(dataSource)
        }
        
        //--------insert your diy TopView
        zyThumbnailTableVC.createTopExpansionViewBlock = { (indexPath: NSIndexPath) -> UIView in
            let topView = TopView.createView(indexPath)!
            topView.delegate = self;
            return topView
        }
        
        let diyBottomView = BottomView.createView()!
        //--------let your inputView component not cover by keyboard automatically (animated) (ZYKeyboardUtil)
        zyThumbnailTableVC.keyboardAdaptiveView = diyBottomView.inputTextField;
        //--------insert your diy BottomView
        zyThumbnailTableVC.createBottomExpansionViewBlock = {
            return diyBottomView
        }
    }
    
    @IBAction func clickEnterButton(sender: UIButton) {
        self.navigationController?.pushViewController(zyThumbnailTableVC, animated: true)
    }
    
    //MARK: delegate
    func zyTableViewDidSelectRow(tableView: UITableView, indexPath: NSIndexPath) {
        zyThumbnailTableVC.tableviewDataList[indexPath.row]
    }
    
    func topViewDidClickFavoriteBtn(topView: TopView) {
        let indexPath = topView.indexPath
        let isFavorite = zyThumbnailTableVC.tableviewDataList[indexPath.row].valueForKey("favorite") as! Bool
//        var dict = (zyThumbnailTableVC.tableviewDataList[indexPath.row] as! NSMutableDictionary)
        //麻烦，dataList还是要装model
//        dict.updateValue(!isFavorite, forKey: "favorite")
//        if dict["favorite"] as? Bool == true {
//            print("成功")
//        }
        zyThumbnailTableVC.reloadMainTableView()
    }
    
    
    //此方法作用是虚拟出tableview数据源，不用理会
    //MARK: -Virtual DataSource
    func createDataSource() -> NSArray {
        let dataSource = NSMutableArray()
        let content = "The lesson of the story, I suggested, was that in some strange sense we are more whole when we are missing something. \n    The man who has everything is in some ways a poor man. \n    He will never know what it feels like to yearn, to hope, to nourish his soul with the dream of something better. \n    He will never know the experience of having someone who loves him give him something he has always wanted or never had."
        
        dataSource.addObject([
            "name" : "NURGIO",
            "avatar" : "avatar0",
            "desc" : "Beijing,Chaoyang District",
            "time" : "3 minute",
            "content" : content,
            "favorite" : false
            ])
        
        dataSource.addObject([
            "name" : "Cheers",
            "avatar" : "avatar1",
            "desc" : "Joined on Dec 18, 2014",
            "time" : "8 minute",
            "content": "You know that you do not need to be in the limelight to gain happiness. If you constantly aim to be in the spotlight, you are looking to others for validation. \n    In actuality, you should just be yourself. People do not like characters that are always in your line of vision and trying to gain your attention.\n    You know that you can just be yourself with others, without the need to be in the limelight. \n    People will see you as a beautiful girl when you are being you, not trying to persistently have all attention on you. \n    Who can have a real conversation with someone who is eagerly looking around and making sure all eyes are on them?",
            "favorite" : false
            ])
        
        dataSource.addObject([
            "name" : "Adleys",
            "avatar" : "avatar2",
            "desc" : "The Technology Studio",
            "time" : "16 minute",
            "content": "To each parent he responded with one line: \"Are you going to help me now?\" \n    And then he continued to dig for his son, stone by stone. \n    The fire chief showed up and tried to pull him off the school s ruins saying, \"Fires are breaking out, explosions are happening everywhere. \n    You’re in danger. We’ll take care of it. Go home.\" To which this loving, caring American father asked, \"Are you going to help me now?\"",
            "favorite" : false
            ])
        
        dataSource.addObject([
            "name" : "Coder_CYX",
            "avatar" : "avatar3",
            "desc" : "Joined on Mar 26, 2013",
            "time" : "21 minute",
            "content": "One year after our \"talk,\" I discovered I had breast cancer. I was thirty-two, the mother of three beautiful young children, and scared. \n    The cancer had metastasized to my lymph nodes and the statistics were not great for long-term survival. \n    After my surgery, friends and loved ones visited and tried to find the right words. No one knew what to say, and many said the wrong things. \n    Others wept, and I tried to encourage them. I clung to hope myself.",
            ])
        
        dataSource.addObject([
            "name" : "Coleman",
            "avatar" : "avatar4",
            "desc" : "Zhejiang University of Technology",
            "time" : "28 minute",
            "content": "You don’t let others hold you back from being yourself. To many people, showing your real face to others is terrifying. But you are always yourself.\n    You don’t let others opinions scare you into being someone else. Instead you choose to be you, flaws and all. You are truly a beautiful girl if you possess this quality. \n    People can often sense when you are being fake, or notice if you are reserved and afraid to speak. To be able to be yourself is inspiring and beautiful, because you are putting yourself out there (without fear).",
            ])
        
        dataSource.addObject([
            "name" : "Moguilay",
            "avatar" : "avatar5",
            "desc" : "zbien.com",
            "time" : "33 minute",
            "content": content,
            ])
        
        dataSource.addObject([
            "name" : "Dikey",
            "avatar" : "avatar6",
            "desc" : "Pluto at the moment",
            "time" : "35 minute",
            "content": content,
            ])
        
        dataSource.addObject([
            "name" : "fmricky",
            "avatar" : "avatar7",
            "desc" : "Waterloo, ON",
            "time" : "42 minute",
            "content": content,
            ])
        
        dataSource.addObject([
            "name" : "Robert Waggott",
            "avatar" : "avatar8",
            "desc" : "Beijing chaoyang",
            "time" : "46 minute",
            "content": content,
            ])
        
        //source dict to model
        let sourceDict = NSArray(array: dataSource)
        let postArray = NSMutableArray()
        for dict in sourceDict {
            let post = Post()
            let handleDict = dict as! Dictionary<String, AnyObject>
            post.name =  validStringForKeyFromDictionary("name", dict: handleDict)
            post.desc = validStringForKeyFromDictionary("desc", dict: handleDict)
            post.time = validStringForKeyFromDictionary("time", dict: handleDict)
            post.content = validStringForKeyFromDictionary("content", dict: handleDict)
            post.avatar = validStringForKeyFromDictionary("avatar", dict: handleDict)
            post.favorite = handleDict["favorite"] as? Bool ?? false
            postArray.addObject(post)
        }
        
        return NSArray(array: postArray)
    }
    
    
    func validStringForKeyFromDictionary(key: String, dict: Dictionary<String, AnyObject>) -> String {
        return dict[key] as? String ?? "illegal"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




//MARK: Model class
class Post: NSObject {
    
    var name: String = ""
    var avatar: String = ""
    var desc: String = ""
    var time: String = ""
    var content: String = ""
    var favorite: Bool = false
    
}
