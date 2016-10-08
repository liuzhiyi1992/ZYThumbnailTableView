//
//  ZYThumbnailTableViewController.swift
//  ZYThumbnailTableView
//
//  Created by lzy on 16/2/9.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

public typealias ConfigureTableViewCellBlock = () -> UITableViewCell?
public typealias UpdateTableViewCellBlock = (_ cell: UITableViewCell, _ indexPath: IndexPath) -> Void
public typealias CreateTopExpansionViewBlock = (_ indexPath: IndexPath) -> UIView?
public typealias CreateBottomExpansionViewBlock = (_ indexPath: IndexPath) -> UIView?


let NOTIFY_NAME_DISMISS_PREVIEW = "NOTIFY_NAME_DISMISS_PREVIEW"
var KEY_INDEXPATH = "KEY_INDEXPATH"


@objc protocol ZYThumbnailTableViewControllerDelegate {
    @objc optional func zyTableViewDidSelectRow(_ tableView: UITableView, indexPath: IndexPath)
}



open class ZYThumbnailTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    //MARK: DEFINE
    fileprivate static let TABLEVIEW_BACKGROUND_COLOR_DEFAULT = UIColor.white
    fileprivate static let CELL_HEIGHT_DEFAULT = CGFloat(100.0)
    fileprivate static let EXPAND_THUMBNAILVIEW_AMPLITUDE_DEFAULT = CGFloat(10)
    fileprivate static let BLUR_BACKGROUND_TINT_COLOR_DEFAULT = UIColor(white: 1.0, alpha: 0.3)
    let MARGIN_KEYBOARD_ADAPTATION = CGFloat(20)
    let TYPE_EXPANSION_VIEW_TOP = "TYPE_EXPANSION_VIEW_TOP"
    let TYPE_EXPANSION_VIEW_BOTTOM = "TYPE_EXPANSION_VIEW_BOTTOM"
    
    
    //MARK: PROPERTY
    /**
     tableView cell height
     */
    open var tableViewCellHeight: CGFloat = CELL_HEIGHT_DEFAULT
    /**
     tableView dataList
     */
    open var tableViewDataList = NSArray()
    /**
     your diy tableView cell ReuseIdentifier
     */
    open var tableViewCellReuseId = "diyCell"
    /**
     tableView backgroundColor
     */
    open var tableViewBackgroudColor = TABLEVIEW_BACKGROUND_COLOR_DEFAULT
    /**
     give me your inputView, I will not allow the keyboard cover him. (ZYKeyboardUtil)
     */
    open var keyboardAdaptiveView: UIView?
    
    
    fileprivate var blurTintColor = BLUR_BACKGROUND_TINT_COLOR_DEFAULT
    fileprivate var blurRadius: CGFloat = 4.0
    fileprivate var saturationDeltaFactor: CGFloat = 1.8
    
    /**
     main tableView
     */
    fileprivate var mainTableView: UITableView!
    /**
     the index you click to expand in tableview
     */
    fileprivate var clickIndexPathRow: Int?
    /**
     the full height of the thumbnailView calculated after spread
     */
    fileprivate var spreadCellHeight: CGFloat?
    /**
     store all alived tableview cell to calculates the full height when be clickd
     */
    fileprivate var cellDictionary: NSMutableDictionary = NSMutableDictionary()
    /**
     copy from the cell which be click ,and show simultaneously
     */
    fileprivate var thumbnailView: UIView!
    /**
     control the panGesture working or not
     */
    fileprivate var thumbnailViewCanPan = true
    /**
     UIDynamicAnimator
     */
    fileprivate var animator: UIDynamicAnimator!
    /**
     the amplitude while you pan(up or down) the thumbnailView
     */
    fileprivate var expandAmplitude = EXPAND_THUMBNAILVIEW_AMPLITUDE_DEFAULT
    /**
     A Util Handed all keyboard events with Block Conveniently
     */
    fileprivate var keyboardUtil: ZYKeyboardUtil!
    
    
    //MARK: BLOCKS
    open lazy var configureTableViewCellBlock: ConfigureTableViewCellBlock = {
        return {
            assertionFailure("ERROR:  -  You must configure the configureTableViewCellBlock")
            return nil;
        }
    }()
    
    open lazy var updateTableViewCellBlock: UpdateTableViewCellBlock = {
        return {
            print("ERROR: You must configure the updateTableViewCellBlock")
        }
    }()
    
//    open lazy var createTopExpansionViewBlock: CreateTopExpansionViewBlock = {
//        return {
//            print("ERROR: You must configure the createTopExpansionViewBlock")
//            return UIView()
//        }
//    }()
    
    open var createTopExpansionViewBlock: CreateTopExpansionViewBlock!
    
//    open lazy var createBottomExpansionViewBlock: CreateBottomExpansionViewBlock = {
//        return {
//            print("ERROR: You must configure the createBottomExpansionViewBlock")
//            return UIView()
//        }
//    }()
    
    open var createBottomExpansionViewBlock: CreateBottomExpansionViewBlock!
    
    
//MARK: FUNCTION
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.mainTableView = UITableView(frame: self.view.frame)
        
        configureKeyboardUtil()
        
        configureTableView()
        
        registerNotification()
        
        guardExpansionViewBlock()
    }
    
    func guardExpansionViewBlock() {
        if createTopExpansionViewBlock == nil {
            createTopExpansionViewBlock = {
                print("WARNNING: You have no configure the createTopExpansionViewBlock")
                return nil
                }()
        }
        
        if createBottomExpansionViewBlock == nil {
            createBottomExpansionViewBlock = {
                print("WARNNING: You have no configure the createBottomExpansionViewBlock")
                return nil;
                }()
        }
    }
    
    override open func viewDidLayoutSubviews() {
        self.mainTableView.updateHeight(self.view.frame.height)
    }
    
    deinit {
        resignNotification()
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(dismissPreview), name: NSNotification.Name(rawValue: NOTIFY_NAME_DISMISS_PREVIEW), object: nil)
    }
    
    func resignNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     used ZYKeyboardUtil githubDemo: https://github.com/liuzhiyi1992/ZYKeyboardUtil
     */
    func configureKeyboardUtil() {
        guard self.keyboardAdaptiveView != nil else {
            return
        }
        
        keyboardUtil = ZYKeyboardUtil()
        //全自动键盘遮盖处理
        keyboardUtil.setAnimateWhenKeyboardAppearAutomaticAnimBlock { [unowned self]() -> [AnyHashable: Any]! in
            let viewDict: [AnyHashable: Any] = [ADAPTIVE_VIEW:self.keyboardAdaptiveView!, CONTROLLER_VIEW:self.view]
            return viewDict
        }
        
        keyboardUtil.setAnimateWhenKeyboardDisappear { [unowned self] _ -> Void in
            
            if self.navigationController == nil || self.navigationController?.navigationBar.isHidden == true {
                //have no navigationBar
                self.view.updateOriginY(0)
            } else {
                self.view.updateOriginY(64)
            }
        }
    }
    
    func configureTableView() {
        self.view.addSubview(mainTableView)
        
        mainTableView.backgroundColor = tableViewBackgroudColor
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.separatorStyle = .none
        mainTableView.reloadData()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataList.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = tableViewCellReuseId
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            //配置cell的Block
            cell = configureTableViewCellBlock()
            cell?.selectionStyle = .none
        }
        guard let nonNilcell = cell else {
            assertionFailure("ERROR: cell can not be nil, plase config cell aright with configureTableViewCellBlock")
            return UITableViewCell(frame: CGRect.zero)
        }
        //这里updateCell
        updateTableViewCellBlock(nonNilcell, indexPath)
        
        //记录所有cell,didSelected后拿出来配置
        cellDictionary.setValue(nonNilcell, forKey: "\((indexPath as NSIndexPath).row)")
        return nonNilcell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == clickIndexPathRow {
            guard let nonNilspreadCellHeight = spreadCellHeight else {
                return tableViewCellHeight
            }
            return nonNilspreadCellHeight
        }
        return tableViewCellHeight
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = cellDictionary.value(forKey: "\((indexPath as NSIndexPath).row)") as? UITableViewCell
        if let nonNilSelectedCell = selectedCell {
            //计算高度
            calculateCell(nonNilSelectedCell, indexPath: indexPath)
            
            //记录点击cell的index
            clickIndexPathRow = (indexPath as NSIndexPath).row
            
            //update Cell
            mainTableView.beginUpdates()
            mainTableView.endUpdates()
            
            //动画纠正thumbnailView
            let tempConvertRect = mainTableView.convert(nonNilSelectedCell.frame, to: self.view)
            var thumbnailViewFrame = self.thumbnailView.frame
            thumbnailViewFrame.origin.y = tempConvertRect.origin.y
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.thumbnailView.frame = thumbnailViewFrame
            })
        } else {
            print("ERROR: can not find the cell in cellDictionary")
        }
    }
    
    func calculateCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let tempConstraint = NSLayoutConstraint(item: cell.contentView,
                                                attribute: NSLayoutAttribute.width,
                                                relatedBy: NSLayoutRelation.equal,
                                                toItem: nil,
                                                attribute: NSLayoutAttribute.notAnAttribute,
                                                multiplier: 1.0,
                                                constant: mainTableView.frame.width)
        cell.contentView.addConstraint(tempConstraint)
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        cell.contentView.removeConstraint(tempConstraint)
        spreadCellHeight = size.height
        previewCell(cell, indexPath: indexPath)
    }
    
    func previewCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        //create previewCover
        let previewCover = UIImageView(frame: mainTableView.frame)
        
        //blur background
        let blurImage = mainTableView.screenShot()
        previewCover.image = blurImage.applyBlur(withRadius: blurRadius, tintColor: blurTintColor, saturationDeltaFactor: saturationDeltaFactor, maskImage: nil)
        previewCover.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPreviewCover(_:)))
        previewCover.addGestureRecognizer(tapGesture)
        self.view.insertSubview(previewCover, aboveSubview: mainTableView)
        
        //animator
        animator = UIDynamicAnimator(referenceView: previewCover)
        
        //create thumbnailView
        let convertRect = mainTableView.convert(cell.frame, to: self.view)
        let thumbnailLocationY = convertRect.minY
        let thumbnailView = UIView(frame: CGRect(x: 0, y: thumbnailLocationY, width: mainTableView.bounds.width, height: tableViewCellHeight))
        
        //binding the indexPath
        objc_setAssociatedObject(thumbnailView, &KEY_INDEXPATH, indexPath, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.thumbnailView = thumbnailView
        thumbnailView.backgroundColor = UIColor.white
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panThumbnailView(_:)))
        thumbnailView.addGestureRecognizer(panGesture)
        previewCover.addSubview(thumbnailView)
        
        //can not copy object in swift, we can only create a new one with configureTableViewCellBlock
        let previewCell = configureTableViewCellBlock()
        previewCell?.selectionStyle = .none
        updateTableViewCellBlock(previewCell!, indexPath)
        
        //layout cell contentView in thumbnailView with VFL
        let contentView = previewCell!.contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["contentView":contentView]
        thumbnailView.addSubview(contentView)
        thumbnailView.clipsToBounds = true
        
        //constraint
        thumbnailView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: .alignAllCenterY, metrics: nil, views: views))
        
        //spread thumbnailView
        guard let nonNilSpreadCellHeight = spreadCellHeight else {
            print("ERROR: spreadCellHeight is nil")
            return
        }
        var toFrame = thumbnailView.frame
        toFrame.size.height = nonNilSpreadCellHeight
        UIView.animate(withDuration: 0.201992, animations: { () -> Void in
            thumbnailView.frame = toFrame
        }, completion: { (finish) -> Void in
            //Overflow screen
            self.handleOverFlowScreen(self.thumbnailView)
        }) 
    }
    
    func tapPreviewCover(_ gesture: UITapGestureRecognizer) {
        dismissPreview()
    }
    
    func dismissPreview() {
        clickIndexPathRow = nil
        //todo 这里给开发者一个选择，要动画过程还是立即完成
        mainTableView.beginUpdates()
        mainTableView.endUpdates()
        UIView.animate(withDuration: 0.301992, animations: { () -> Void in
            self.thumbnailView.superview?.alpha = 0
        }, completion: { (finish) -> Void in
            self.thumbnailView.superview?.removeFromSuperview()
            self.thumbnailViewCanPan = true
        }) 
    }
    
    func panThumbnailView(_ gesture: UIPanGestureRecognizer) {
        let thumbnailViewHeight = gesture.view!.bounds.height
        let gestureTranslation = gesture.translation(in: gesture.view)
        let thresholdValue = thumbnailViewHeight * 0.3
        if thumbnailViewCanPan {
            if gestureTranslation.y > thresholdValue {
                thumbnailViewCanPan = false
                let indexPath = objc_getAssociatedObject(gesture.view, &KEY_INDEXPATH) as! IndexPath
                layoutTopView(indexPath)
            } else if gestureTranslation.y < -thresholdValue {
                thumbnailViewCanPan = false
                let indexPath = objc_getAssociatedObject(gesture.view, &KEY_INDEXPATH) as! IndexPath
                layoutBottomView(indexPath)
            }
        }
        //gesture state
        switch gesture.state {
        case .began:
            animator.removeAllBehaviors()
            break
        case .ended:
            break
        default:
            break
        }
    }
    
    fileprivate func shock(_ view: UIView, type: String) {
        //超出tableview范围不shock
        var expandShockAmplitude: CGFloat!
        let convertRect = view.superview?.convert(view.frame, to: self.view)
        guard let nonNilConvertRect = convertRect else {
            print("ERROR: convertRect error")
            return
        }
        if type == TYPE_EXPANSION_VIEW_TOP {
            expandShockAmplitude = self.expandAmplitude
            if nonNilConvertRect.maxY > self.view.frame.height {
                //超出下面
                return
            }
        } else if (type == TYPE_EXPANSION_VIEW_BOTTOM) {
            expandShockAmplitude = -self.expandAmplitude
            if nonNilConvertRect.minY < 0 {
                //超出上面
                return
            }
        } else {
            print("ERROR: function shock parameter illegal")
            return
        }
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: 0.1)
            var snapPoint = view.center
            snapPoint.y += expandShockAmplitude
            var snapBehavior = UISnapBehavior(item: view, snapTo: snapPoint)
            snapBehavior.damping = 0.9
            DispatchQueue.main.async(execute: { () -> Void in
                self.animator.addBehavior(snapBehavior)
            })
            
            Thread.sleep(forTimeInterval: 0.1)
            
            snapPoint.y -= expandShockAmplitude
            snapBehavior = UISnapBehavior(item: view, snapTo: snapPoint)
            snapBehavior.damping = 0.9
            DispatchQueue.main.async(execute: { () -> Void in
                self.animator.removeAllBehaviors()
                self.animator.addBehavior(snapBehavior)
            })
        }
        
        
//        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { () -> Void in
//            Thread.sleep(forTimeInterval: 0.1)
//            var snapPoint = view.center
//            snapPoint.y += expandShockAmplitude
//            var snapBehavior = UISnapBehavior(item: view, snapTo: snapPoint)
//            snapBehavior.damping = 0.9
//            DispatchQueue.main.async(execute: { () -> Void in
//                self.animator.addBehavior(snapBehavior)
//            })
//            
//            Thread.sleep(forTimeInterval: 0.1)
//            
//            snapPoint.y -= expandShockAmplitude
//            snapBehavior = UISnapBehavior(item: view, snapTo: snapPoint)
//            snapBehavior.damping = 0.9
//            DispatchQueue.main.async(execute: { () -> Void in
//                self.animator.removeAllBehaviors()
//                self.animator.addBehavior(snapBehavior)
//            })
//        }
    }
    
    fileprivate func layoutTopView(_ indexPath: IndexPath) {
        let contentView = thumbnailView.subviews.first
        let nullableTopView = createTopExpansionViewBlock(indexPath)
        guard let topView = nullableTopView else {
            thumbnailViewCanPan = true
            return
        }
        topView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.addSubview(topView)
        let views = ["contentView":contentView!, "topView":topView]
        
        //remove all constraints
//        _ = thumbnailView.constraints.map { $0.isActive = false }
        _ = thumbnailView.constraints.map { thumbnailView.removeConstraint($0) }
        thumbnailView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topView]-0-[contentView]|", options: .alignAllCenterX, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topView]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views))
        
        //update Frame
        topView.updateOriginY(-topView.bounds.height)
        UIView.animate(withDuration: 0.201992, animations: { () -> Void in
            self.thumbnailView.updateHeight(self.thumbnailView.bounds.height + topView.bounds.height)
            contentView?.updateOriginY(topView.bounds.height)
            topView.updateOriginY(0)
        }, completion: { (finish) -> Void in
            //Overflow screen
            self.handleOverFlowScreen(self.thumbnailView)
        }) 
        //shock
        shock(thumbnailView, type: TYPE_EXPANSION_VIEW_TOP)
    }
    
    fileprivate func layoutBottomView(_ indexPath: IndexPath) {
        let contentView = thumbnailView.subviews.first
        let nullableBottomView = createBottomExpansionViewBlock(indexPath)
        guard let bottomView = nullableBottomView else {
            thumbnailViewCanPan = true
            return
        }
        thumbnailViewCanPan = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.addSubview(bottomView)
        let views = ["contentView":contentView!, "bottomView":bottomView]
        
        //remove all constraints
//        _ = thumbnailView.constraints.map { $0.isActive = false }
        _ = thumbnailView.constraints.map { thumbnailView.removeConstraint($0) }
        thumbnailView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]-0-[bottomView]|", options: .alignAllCenterX, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomView]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views))
        thumbnailView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views))
        
        //update Frame
        UIView.animate(withDuration: 0.201992, animations: { () -> Void in
            self.thumbnailView.updateHeight(self.thumbnailView.bounds.height + bottomView.bounds.height)
            self.thumbnailView.updateOriginY(self.thumbnailView.frame.origin.y - bottomView.bounds.height)
        }, completion: { (finish) -> Void in
            //Overflow screen
            if self.thumbnailView.frame.origin.y < 0 {
                UIView.animate(withDuration: 0.201992, animations: { () -> Void in
                    self.thumbnailView.updateOriginY(0)
                })
            }
        }) 
        //shock
        shock(thumbnailView, type: TYPE_EXPANSION_VIEW_BOTTOM)
    }
    
    fileprivate func handleOverFlowScreen(_ handleView: UIView) {
        let keyWindow = UIApplication.shared.keyWindow
        let convertRect = handleView.superview?.convert(handleView.frame, to: keyWindow)
        guard let nonNilConvertRect = convertRect else {
            print("ERROR: can not convert Rect error")
            return
        }
        let diff = nonNilConvertRect.maxY - UIScreen.main.bounds.maxY
        if diff > 0 {
            UIView.animate(withDuration: 0.201992, animations: { () -> Void in
                handleView.updateOriginY(handleView.frame.origin.y - diff)
            })
        }
    }
    
    fileprivate func movingPath(_ startPoint: CGPoint, keyPoints: CGPoint...) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: startPoint)
        for point in keyPoints {
            path.addLine(to: point)
        }
        return path
    }
    
    open func reloadMainTableView() {
        mainTableView.reloadData()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: UIView extension
extension UIView {
    func updateOriginX(_ originX: CGFloat) {
        self.frame = CGRect(x: originX, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height);
    }
    
    func updateOriginY(_ originY: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: originY, width: self.frame.size.width, height: self.frame.size.height);
    }
    
    func updateCenterX(_ centerX: CGFloat) {
        self.center = CGPoint(x: centerX, y: self.center.y);
    }
    
    func updateCenterY(_ centerY: CGFloat) {
        self.center = CGPoint(x: self.center.x, y: centerY);
    }
    
    func updateWidth(_ width: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.size.height);
    }
    
    func updateHeight(_ height: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: height);
    }
    
    func screenShot() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        if self.responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
            //ios7以上
            self.drawHierarchy(in: self.frame, afterScreenUpdates: false)
        } else {
            //ios7以下
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        var screenShotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageData = UIImageJPEGRepresentation(screenShotImage!, 0.7)
        screenShotImage = UIImage(data: imageData!)
        return screenShotImage!
    }
    
}



