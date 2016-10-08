//
//  BottomView.swift
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/14.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

class BottomView: UIView {
    
    @IBOutlet weak var inputTextField: UITextField!
    
    class func createView() -> BottomView? {
        let view = Bundle.main.loadNibNamed("BottomView", owner: nil, options: nil)?.first as? BottomView
        guard view != nil else {
            assertionFailure("ERROR: can not load nib \"BottomView\"")
            return nil
        }
        return view
    }
    
    @IBAction func clickDismissButton(_ sender: AnyObject) {
//        self.inputTextField.resignFirstResponder()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFY_NAME_DISMISS_PREVIEW), object: nil)
    }
}
