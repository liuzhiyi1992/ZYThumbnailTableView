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
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var favoriteMarkImageView: UIImageView!
    @IBOutlet weak var unreadMarkImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class func createCell() -> DIYTableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("DIYTableViewCell", owner: nil, options: nil).first as? DIYTableViewCell
        assert(cell != nil, "can not load nib named DIYTableViewCell")
        return cell!
    }
    
    func updateCell(post: Post) {
        nameLabel.text = post.name
        descLabel.text = post.desc
        timeLabel.text = post.time
        contentLabel.text = post.content
        avatarImageView.image = UIImage(named: post.avatar) ?? UIImage(named: "avatar0")
        
        self.favoriteMarkImageView.hidden = !post.favorite
        self.unreadMarkImageView.hidden = post.read
    }
    
}
