//
//  BottomView.swift
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/14.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

class BottomView: UIView {
    
    class func createView() -> BottomView? {
        let view = NSBundle.mainBundle().loadNibNamed("BottomView", owner: nil, options: nil).first as? BottomView
        guard view != nil else {
            assertionFailure("ERROR: can not load nib \"BottomView\"")
            return nil
        }
        return view
    }
    
    @IBAction func clickDismissButton(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFY_NAME_DISMISS_PREVIEW, object: nil)
    }
}
