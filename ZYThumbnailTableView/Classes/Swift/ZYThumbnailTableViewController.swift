//
//  ZYThumbnailTableViewController.swift
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/9.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

typealias ConfigureTableViewCellBlock = () -> UITableViewCell?
typealias SpreadCellAnimationBlick = (cell: UITableViewCell) -> Void
typealias CreateTopExpansionViewBlock = () -> UIView
typealias CreateBottomExpansionViewBlock = () -> UIView

let NOTIFY_NAME_DISMISS_PREVIEW = "NOTIFY_NAME_DISMISS_PREVIEW"


class ZYThumbnailTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
//MARK: DEFINE
    private static let CELL_HEIGHT_DEFAULT = CGFloat(100.0)
    private static let EXPAND_THUMBNAILVIEW_AMPLITUDE_DEFAULT = CGFloat(10)
    let TYPE_EXPANSION_VIEW_TOP = "TYPE_EXPANSION_VIEW_TOP"
    let TYPE_EXPANSION_VIEW_BOTTOM = "TYPE_EXPANSION_VIEW_BOTTOM"
    
//MARK: PROPERTY
    let cellHeight: CGFloat = CELL_HEIGHT_DEFAULT
    var dataList = NSArray()
    var mainTableView: UITableView!
    var clickIndexPathRow: Int?
    var spreadCellHeight: CGFloat?

    var cellSpreadHeight: CGFloat?
    
    var cellDictionary: NSMutableDictionary = NSMutableDictionary()
    
    var thumbnailView: UIView!
    
    var thumbnailViewCanPan = true
    
    var animator: UIDynamicAnimator!
    
    let expandAmplitude = EXPAND_THUMBNAILVIEW_AMPLITUDE_DEFAULT
    
//MARK: BLOCKS
    lazy var configureTableViewCellBlock: ConfigureTableViewCellBlock = {
        return {
            assertionFailure("ERROR: You must configure the configureTableViewCellBlock")
            return nil
        }
    }()
    
    lazy var spreadCellAnimationBlock: SpreadCellAnimationBlick = {
        return {
            assertionFailure("ERROR: You must configure the spreadCellAnimationBlock")
        }
    }()
    
    lazy var createTopExpansionViewBlock: CreateTopExpansionViewBlock = {
        return {
            assertionFailure("ERROR: You must configure the createTopExpansionViewBlock")
            return UIView()
        }
    }()
    
    lazy var createBottomExpansionViewBlock: CreateBottomExpansionViewBlock = {
        return {
            assertionFailure("ERROR: You must configure the createBottomExpansionViewBlock")
            return UIView()
        }
    }()
    
//MARK: FUNCTION
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "ZYThumbnailTableViewCell"
        self.mainTableView = UITableView(frame: self.view.frame)
        self.view.addSubview(mainTableView)
        
        mainTableView.backgroundColor = UIColor(red: 53/255.0, green: 72/255.0, blue: 83/255.0, alpha: 1.0)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.separatorStyle = .None
        mainTableView.reloadData()
        
        registerNotification()
    }
    
    deinit {
        resignNotification()
    }
    
    func registerNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissPreview", name: NOTIFY_NAME_DISMISS_PREVIEW, object: nil)
    }
    
    func resignNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return dataList.count
        return 12
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //todo 注意自定义的cell的id要设置成这个
        let identifier = "zythumbnailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        if cell == nil {
            //这里放一个Block 返回值 只能 是一个uitableviewCell
            //我觉得，也可以在里面update
            cell = configureTableViewCellBlock()
            cell?.selectionStyle = .None
        }
        
        guard let nonNilcell = cell else {
            assertionFailure("ERROR: cell can not be nil, plase config cell with configureTableViewCellBlock")
            return UITableViewCell(frame: CGRectZero)
        }
        //计算cell完全展开的高度，记录
        cellDictionary.setValue(cell, forKey: "\(indexPath.row)")
        return nonNilcell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == clickIndexPathRow {
            guard let nonNilspreadCellHeight = spreadCellHeight else {
                return cellHeight
            }
            return nonNilspreadCellHeight
        }
        return cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = cellDictionary.valueForKey("\(indexPath.row)") as? UITableViewCell
        if let nonNilSelectedCell = selectedCell {
            //计算高度
            calculateCell(nonNilSelectedCell, indexPath: indexPath)
            
            //记录点击cell的index
            clickIndexPathRow = indexPath.row
            
            //update Cell
            mainTableView.beginUpdates()
            mainTableView.endUpdates()
            
            //动画纠正thumbnailView
            let tempConvertRect = mainTableView.convertRect(nonNilSelectedCell.frame, toView: self.view)
            var thumbnailViewFrame = self.thumbnailView.frame
            thumbnailViewFrame.origin.y = tempConvertRect.origin.y
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.thumbnailView.frame = thumbnailViewFrame
            })
        } else {
            print("ERROR: can not find the cell in cellDictionary")
        }
    }
    
    func calculateCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let tempConstraint = NSLayoutConstraint(item: cell.contentView,
                                           attribute: NSLayoutAttribute.Width,
                                           relatedBy: NSLayoutRelation.Equal,
                                              toItem: nil,
                                           attribute: NSLayoutAttribute.NotAnAttribute,
                                          multiplier: 1.0,
                                            constant: CGRectGetWidth(mainTableView.frame))
        cell.contentView.addConstraint(tempConstraint)
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        cell.contentView.removeConstraint(tempConstraint)
        spreadCellHeight = size.height
        previewCell(cell, index: indexPath.row)
    }
    
    func previewCell(cell: UITableViewCell, index: Int) {
        //create previewCover
        let previewCover = UIView(frame: mainTableView.frame)
        previewCover.backgroundColor = UIColor.blackColor()
        previewCover.alpha = 0.9
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapPreviewCover:")
        previewCover.addGestureRecognizer(tapGesture)
        self.view.insertSubview(previewCover, aboveSubview: mainTableView)
        //animator
        animator = UIDynamicAnimator(referenceView: previewCover)
        
        //create thumbnailView
        let convertRect = mainTableView.convertRect(cell.frame, toView: self.view)
        let thumbnailLocationY = CGRectGetMinY(convertRect)
        let thumbnailView = UIView(frame: CGRectMake(0, thumbnailLocationY, mainTableView.bounds.width, cellHeight))
        self.thumbnailView = thumbnailView
        thumbnailView.backgroundColor = UIColor.whiteColor()
        let panGesture = UIPanGestureRecognizer(target: self, action: "panThumbnailView:")
        thumbnailView.addGestureRecognizer(panGesture)
        previewCover.addSubview(thumbnailView)
        
        //can not copy object in swift, we can only create a new one with configureTableViewCellBlock
        let previewCell = configureTableViewCellBlock()
        previewCell?.selectionStyle = .None
        
        //layout cell contentView in thumbnailView with VFL
        let contentView = previewCell!.contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["contentView":contentView]
        thumbnailView.addSubview(contentView)
        thumbnailView.clipsToBounds = true
        
        //dont contain the bottom constraint here
        thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: .AlignAllCenterY, metrics: nil, views: views))
        
        //spread thumbnailView
        guard let nonNilSpreadCellHeight = spreadCellHeight else {
            print("ERROR: spreadCellHeight is nil")
            return
        }
        var toFrame = thumbnailView.frame
        toFrame.size.height = nonNilSpreadCellHeight
        UIView.animateWithDuration(0.201992, animations: { () -> Void in
            thumbnailView.frame = toFrame
            }) { (finish) -> Void in
                //Overflow screen
                self.handleOverFlowScreen(self.thumbnailView)
        }
    }
    
    func tapPreviewCover(gesture: UITapGestureRecognizer) {
        dismissPreview()
    }
    
    func dismissPreview() {
        clickIndexPathRow = nil
        //todo 这里给开发者一个选择，要动画过程还是立即完成
        //        mainTableView.reloadData()
        mainTableView.beginUpdates()
        mainTableView.endUpdates()
        UIView.animateWithDuration(0.301992, animations: { () -> Void in
            self.thumbnailView.superview?.alpha = 0
            }) { (finish) -> Void in
                self.thumbnailView.superview?.removeFromSuperview()
                self.thumbnailViewCanPan = true
        }
    }
    
    func panThumbnailView(gesture: UIPanGestureRecognizer) {
        let thumbnailViewHeight = gesture.view!.bounds.height
        let gestureTranslation = gesture.translationInView(gesture.view)
        let thresholdValue = thumbnailViewHeight * 0.3
        if thumbnailViewCanPan {
            if gestureTranslation.y > thresholdValue {
                layoutTopView()
                thumbnailViewCanPan = false
            } else if gestureTranslation.y < -thresholdValue {
                layoutBottomView()
                thumbnailViewCanPan = false
            }
        }
        //gesture state
        switch gesture.state {
        case .Began:
            animator.removeAllBehaviors()
            break
        case .Ended:
            break
        default:
            break
        }
    }
    
    
    func shock(view: UIView, type: String) {
        //超出tableview范围不shock
        var expandShockAmplitude: CGFloat!
        let convertRect = view.superview?.convertRect(view.frame, toView: self.view)
        guard let nonNilConvertRect = convertRect else {
            print("ERROR: convertRect error")
            return
        }
        if type == TYPE_EXPANSION_VIEW_TOP {
            expandShockAmplitude = self.expandAmplitude
            if CGRectGetMaxY(nonNilConvertRect) > CGRectGetHeight(self.view.frame) {
                //超出下面
                return
            }
        } else if (type == TYPE_EXPANSION_VIEW_BOTTOM) {
            expandShockAmplitude = -self.expandAmplitude
            if CGRectGetMinY(nonNilConvertRect) < 0 {
                //超出上面
                return
            }
        } else {
            print("ERROR: function shock parameter illegal")
            return
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            NSThread.sleepForTimeInterval(0.1)
            var snapPoint = view.center
            snapPoint.y += expandShockAmplitude
            var snapBehavior = UISnapBehavior(item: view, snapToPoint: snapPoint)
            snapBehavior.damping = 0.9
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.animator.addBehavior(snapBehavior)
            })
            
            NSThread.sleepForTimeInterval(0.1)
            
            snapPoint.y -= expandShockAmplitude
            snapBehavior = UISnapBehavior(item: view, snapToPoint: snapPoint)
            snapBehavior.damping = 0.9
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.animator.removeAllBehaviors()
                self.animator.addBehavior(snapBehavior)
            })
            
        }
    }
    
    /*
    func layoutExpansionView(type: String) {
        let contentView = thumbnailView.subviews.first
        var expansionView: UIView!
        
        //create ExpansionView
        if type == TYPE_EXPANSION_VIEW_TOP {
            expansionView = TopView.createView()!
        } else if type == TYPE_EXPANSION_VIEW_BOTTOM {
            expansionView = BottomView.createView()!
        }

        //layout expansionView
        expansionView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.addSubview(expansionView)
        
        //Constraint
        let views = ["contentView":contentView!, "expansionView":expansionView]
        _ = thumbnailView.constraints.map { $0.active = false }
        if type == TYPE_EXPANSION_VIEW_TOP {
            thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[expansionView]-0-[contentView]|", options: .AlignAllCenterX, metrics: nil, views: views))
        } else if type == TYPE_EXPANSION_VIEW_BOTTOM {
            thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]-0-[expansionView]|", options: .AlignAllCenterX, metrics: nil, views: views))
        }
        thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[expansionView]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views))

        //update Frame
        if type == TYPE_EXPANSION_VIEW_TOP {
            expansionView.updateOriginY(-expansionView.bounds.height)
            UIView.animateWithDuration(0.3) { () -> Void in
                self.thumbnailView.updateHeight(self.thumbnailView.bounds.height + expansionView.bounds.height)
                contentView?.updateOriginY(expansionView.bounds.height)
                expansionView.updateOriginY(0)
            }
        } else if type == TYPE_EXPANSION_VIEW_BOTTOM {
            UIView.animateWithDuration(0.301992, animations: { () -> Void in
                self.thumbnailView.updateHeight(self.thumbnailView.bounds.height + expansionView.bounds.height)
            }, completion: { (finish) -> Void in
                
            })
        }
    }
    */
    
    func layoutTopView() {
        let contentView = thumbnailView.subviews.first
        let topView = createTopExpansionViewBlock()
        topView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.addSubview(topView)
        let views = ["contentView":contentView!, "topView":topView]
        
        //remove all constraints
        _ = thumbnailView.constraints.map { $0.active = false }
        thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topView]-0-[contentView]|", options: .AlignAllCenterX, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[topView]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views))
        
        //update Frame
        topView.updateOriginY(-topView.bounds.height)
        UIView.animateWithDuration(0.201992, animations: { () -> Void in
            self.thumbnailView.updateHeight(self.thumbnailView.bounds.height + topView.bounds.height)
                contentView?.updateOriginY(topView.bounds.height)
                topView.updateOriginY(0)
            }) { (finish) -> Void in
                //Overflow screen
                self.handleOverFlowScreen(self.thumbnailView)
        }
        //shock
        shock(thumbnailView, type: TYPE_EXPANSION_VIEW_TOP)
        
        /*
        
        let boundsAnim = CABasicAnimation(keyPath: "bounds")
        let frombounds = self.thumbnailView.bounds
        var tobounds = self.thumbnailView.bounds
        tobounds.size.height = thumbnailView.layer.frame.height + topView.layer.frame.height
        
        boundsAnim.fromValue = frombounds as? AnyObject
        boundsAnim.toValue = tobounds as? AnyObject
        boundsAnim.duration = 3.201992
        boundsAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        
        let thumbnailViewPositionAnim = CAKeyframeAnimation(keyPath: "position")
        let thumbnailViewPosition = self.thumbnailView.layer.position
        let path = UIBezierPath()
        path.moveToPoint(thumbnailViewPosition)
        path.addLineToPoint(CGPointMake(thumbnailViewPosition.x, thumbnailViewPosition.y + 0.5*topView.layer.frame.height))
        thumbnailViewPositionAnim.path = path.CGPath
        thumbnailViewPositionAnim.duration = 3.201992
        thumbnailViewPositionAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        
        
        let group = CAAnimationGroup()
        group.animations = [boundsAnim ,thumbnailViewPositionAnim]
        group.duration = 3.201992
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        self.thumbnailView.layer.addAnimation(group, forKey: "group")
        
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
//        thumbnailView.frame.size.height = thumbnailView.layer.frame.height + topView.layer.frame.height
        thumbnailView.layer.bounds = tobounds
        self.thumbnailView.layer.position = CGPointMake(thumbnailViewPosition.x, thumbnailViewPosition.y + 0.5*topView.layer.frame.height)
        CATransaction.commit()
        */
        
        
        
        
        //shock Anim
        /*
        let shockAmplitude = CGFloat(10)
        let contentViewPositionAnim = CAKeyframeAnimation(keyPath: "position")
        let contentViewPosition = contentView!.layer.position
        let contentViewPath = movingPath(contentViewPosition,
                                         keyPoints: CGPointMake(contentViewPosition.x, contentViewPosition.y + topView.bounds.height + shockAmplitude),
                                                    CGPointMake(contentViewPosition.x, contentViewPosition.y + topView.bounds.height - 0.5 * shockAmplitude),
                                                    CGPointMake(contentViewPosition.x, contentViewPosition.y + topView.bounds.height))
        contentViewPositionAnim.path = contentViewPath.CGPath
        contentViewPositionAnim.keyTimes = [0.0, 0.8, 0.9, 1.0]
        contentViewPositionAnim.duration = 2.3
        contentViewPositionAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        contentView?.layer.addAnimation(contentViewPositionAnim, forKey: "contentview")
        
        
        
        let topViewPositionAnim = CAKeyframeAnimation(keyPath: "position")
        let topViewPosition = topView.layer.position
        let topViewPath = movingPath(topViewPosition,
                                     keyPoints: CGPointMake(topViewPosition.x, topViewPosition.y + topView.bounds.height + shockAmplitude),
                                                CGPointMake(topViewPosition.x, topViewPosition.y + topView.bounds.height - 0.5 * shockAmplitude),
                                                CGPointMake(topViewPosition.x, topViewPosition.y + topView.bounds.height))
        topViewPositionAnim.path = topViewPath.CGPath
        topViewPositionAnim.keyTimes = [0.0, 0.8, 0.9, 1.0]
        topViewPositionAnim.duration = 2.3
        topViewPositionAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        topView.layer.addAnimation(topViewPositionAnim, forKey: "topview")
        
        
        
        contentView?.layer.position = CGPointMake(contentViewPosition.x, contentViewPosition.y + topView.bounds.height)
        topView.layer.position = CGPointMake(topView.layer.position.x, topViewPosition.y + topView.bounds.height)
        */
        
    }
    
    func movingPath(startPoint: CGPoint, keyPoints: CGPoint...) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        for point in keyPoints {
            path.addLineToPoint(point)
        }
        return path
    }
    
    func layoutBottomView() {
        let contentView = thumbnailView.subviews.first
        let bottomView = createBottomExpansionViewBlock()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.addSubview(bottomView)
        let views = ["contentView":contentView!, "bottomView":bottomView]
        
        //remove all constraints
        _ = thumbnailView.constraints.map { $0.active = false }
        thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]-0-[bottomView]|", options: .AlignAllCenterX, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottomView]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views))
        
        //update Frame
        UIView.animateWithDuration(0.201992, animations: { () -> Void in
            self.thumbnailView.updateHeight(self.thumbnailView.bounds.height + bottomView.bounds.height)
            self.thumbnailView.updateOriginY(self.thumbnailView.frame.origin.y - bottomView.bounds.height)
            }) { (finish) -> Void in
                //Overflow screen
                if self.thumbnailView.frame.origin.y < 0 {
                    UIView.animateWithDuration(0.201992, animations: { () -> Void in
                        self.thumbnailView.updateOriginY(0)
                    })
                }
        }
        //shock
        shock(thumbnailView, type: TYPE_EXPANSION_VIEW_BOTTOM)
        
    }
    
    func handleOverFlowScreen(handleView: UIView) {
        let keyWindow = UIApplication.sharedApplication().keyWindow
        let convertRect = handleView.superview?.convertRect(handleView.frame, toView: keyWindow)
        guard let nonNilConvertRect = convertRect else {
            print("ERROR: can not convert Rect error")
            return
        }
        let diff = CGRectGetMaxY(nonNilConvertRect) - CGRectGetMaxY(UIScreen.mainScreen().bounds)
        if diff > 0 {
            UIView.animateWithDuration(0.201992, animations: { () -> Void in
                handleView.updateOriginY(handleView.frame.origin.y - diff)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



extension UIView {
    func updateOriginX(originX: CGFloat) {
        self.frame = CGRectMake(originX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    
    func updateOriginY(originY: CGFloat) {
        self.frame = CGRectMake(self.frame.origin.x, originY, self.frame.size.width, self.frame.size.height);
    }
    
    func updateCenterX(centerX: CGFloat) {
        self.center = CGPointMake(centerX, self.center.y);
    }
    
    func updateCenterY(centerY: CGFloat) {
        self.center = CGPointMake(self.center.x, centerY);
    }
    
    func updateWidth(width: CGFloat) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
    }
    
    func updateHeight(height: CGFloat) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    }
}
