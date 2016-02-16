//
//  ZYThumbnailTableViewCell.swift
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/8.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

class DIYTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    class func createCell() -> DIYTableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("DIYTableViewCell", owner: nil, options: nil).first as? DIYTableViewCell
        assert(cell != nil, "can not load nib named DIYTableViewCell")
        return cell!
    }
    
    
    func updateCell(dict: [String : String]) {
        nameLabel.text = dict["name"] ?? "error"
        descLabel.text = dict["desc"] ?? "error"
        timeLabel.text = dict["time"] ?? "error"
        contentLabel.text = dict["content"] ?? "error"
        print("更新成功")
    }
    
    /*
    func configureThumbnail(thumbnailViewNibName: String) {
        let thumbnailView = NSBundle.mainBundle().loadNibNamed(thumbnailViewNibName, owner: nil, options: nil).first as? UIView
        self.thumbnailView = thumbnailView
        assert(thumbnailView != nil, "can not load nib named \(thumbnailViewNibName)")
    
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
