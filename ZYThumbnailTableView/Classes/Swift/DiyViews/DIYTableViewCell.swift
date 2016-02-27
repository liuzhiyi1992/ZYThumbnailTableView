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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class func createCell() -> DIYTableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("DIYTableViewCell", owner: nil, options: nil).first as? DIYTableViewCell
        assert(cell != nil, "can not load nib named DIYTableViewCell")
        return cell!
    }
    
    func updateCell(dict: [String : AnyObject]) {
        nameLabel.text = validStringForKeyFromDictionary("name", dict: dict)
        descLabel.text = validStringForKeyFromDictionary("desc", dict: dict)
        timeLabel.text = validStringForKeyFromDictionary("time", dict: dict)
        contentLabel.text = validStringForKeyFromDictionary("content", dict: dict)
        let imageName = validStringForKeyFromDictionary("avatar", dict: dict)
        avatarImageView.image = UIImage(named: imageName) ?? UIImage(named: "avatar0")
    }
    
    func validStringForKeyFromDictionary(key: String, dict: Dictionary<String, AnyObject>) -> String {
        return dict[key] as? String ?? "illegal"
    }
    
}
