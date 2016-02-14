//
//  ZYThumbnailTableViewCell.swift
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/8.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

class ZYThumbnailTableViewCell: UITableViewCell {

//    var thumbnailView: UIView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    class func createCell() -> ZYThumbnailTableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("ZYThumbnailTableViewCell", owner: nil, options: nil).first as? ZYThumbnailTableViewCell
        assert(cell != nil, "can not load nib named ZYThumbnailTableViewCell")
        
//        cell?.configureThumbnail("DemoThumbnailView")
        
        return cell!
    }
    
    
    func updateCell() {
//        contentLabel.text = "更新成功啦"
        print("更新成功")
//        contentLabel.numberOfLines = 0
    }
    
    
    
    /*
    func configureThumbnail(thumbnailViewNibName: String) {
        let thumbnailView = NSBundle.mainBundle().loadNibNamed(thumbnailViewNibName, owner: nil, options: nil).first as? UIView
        self.thumbnailView = thumbnailView
        assert(thumbnailView != nil, "can not load nib named \(thumbnailViewNibName)")
        
        //使用VFL加入内嵌缩略view
        thumbnailView?.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["thumbnailView":thumbnailView!]
        self.addSubview(thumbnailView!)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[thumbnailView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[thumbnailView]|", options: .AlignAllCenterY, metrics: nil, views: views))
    }
    */
    
    
    
    
    
    func spreadLabel() {
        //只是uiview哦?
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //这个是什么鬼方法
        // Configure the view for the selected state
    }
    
}
