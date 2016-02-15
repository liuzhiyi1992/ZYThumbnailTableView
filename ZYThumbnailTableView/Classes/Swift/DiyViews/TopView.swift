//
//  TopView.swift
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/14.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

class TopView: UIView {

    class func createView() -> TopView? {
        let view = NSBundle.mainBundle().loadNibNamed("TopView", owner: nil, options: nil).first as? TopView
        guard view != nil else {
            assertionFailure("ERROR: can not load nib \"TopView\"")
            return nil
        }
        return view
    }
    
    @IBAction func clickDismissButton(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFY_NAME_DISMISS_PREVIEW, object: nil)
    }
    
    
}
