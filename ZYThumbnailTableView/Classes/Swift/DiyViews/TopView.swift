//
//  TopView.swift
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/14.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit


@objc protocol DiyTopViewDelegate {
    optional func topViewDidClickFavoriteBtn(topView: TopView)
    optional func topViewDidClickShareBtn(topView: TopView)
}

//selected A7DA55
//default  AAAAAA
class TopView: UIView {
    
    let TAG_BUTTON_GENERAL = 10
    let TAG_BUTTON_SELECTED = 20
    
    var indexPath: NSIndexPath!
    var delegate: DiyTopViewDelegate?

    class func createView(indexPath: NSIndexPath) -> TopView? {
        let view = NSBundle.mainBundle().loadNibNamed("TopView", owner: nil, options: nil).first as? TopView
        guard view != nil else {
            assertionFailure("ERROR: can not load nib \"TopView\"")
            return nil
        }
        view!.indexPath = indexPath
        return view
    }
    
    @IBAction func clickFavoriteButton(sender: UIButton) {
        
        if sender.tag == TAG_BUTTON_GENERAL {
            sender.setTitleColor(UIColor(red: 167/255.0, green: 218/255.0, blue: 85/255.0, alpha: 1.0), forState: .Normal)
            sender.setImage(UIImage(named: "star_solid"), forState: .Normal)
            sender.tag = TAG_BUTTON_SELECTED
        } else if sender.tag == TAG_BUTTON_SELECTED {
            sender.setTitleColor(UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1.0), forState: .Normal)
            sender.setImage(UIImage(named: "star_hollow"), forState: .Normal)
            sender.tag = TAG_BUTTON_GENERAL
        }
        
        //notification
        let notification = NSNotification(name: "NOTIFY_NAME_DISMISS_PREVIEW", object: nil)
        NSNotificationCenter.defaultCenter().performSelector("postNotification:", withObject: notification, afterDelay: 0.25)
        
        //delegate
        if let nonNilDelegate = delegate {
            nonNilDelegate.topViewDidClickFavoriteBtn?(self)
        }
        
    }
    
    
}
