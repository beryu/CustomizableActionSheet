//
//  CustomizableActionSheet.swift
//  CustomizableActionSheet
//
//  Created by Ryuta Kibe on 2015/12/22.
//  Copyright © 2015年 blk. All rights reserved.
//

import UIKit

@objc enum CustomizableActionSheetItemType: Int {
    case Button
    case View
}

// Can't define CustomizableActionSheetItem as struct because Obj-C can't see struct definition.
class CustomizableActionSheetItem: NSObject {
    
    // MARK: - Internal properties
    var type: CustomizableActionSheetItemType = .Button
    var height: CGFloat = 30
    
    // type = .View
    var view: UIView?
    
    // type = .Button
    var label: String?
    var textColor: UIColor = UIColor(red: 0, green: 122, blue: 255, alpha: 1.0)
    var backgroundColor: UIColor = UIColor.whiteColor()
    var font: UIFont? = nil
    var selectAction: ((actoinSheet: CustomizableActionSheet) -> Void)? = nil
    
    // MARK: - Private properties
    private var element: UIView? = nil
    
    convenience init(type: CustomizableActionSheetItemType, height: CGFloat) {
        self.init()
        
        self.type = type
        self.height = height
    }
}

private class ActionSheetItemView: UIView {
    var subview: UIView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setting()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setting()
    }
    
    init() {
        super.init(frame: CGRectZero)
        self.setting()
    }
    
    func setting() {
        self.clipsToBounds = true
    }
    
    override func addSubview(view: UIView) {
        super.addSubview(view)
        self.subview = view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let subview = self.subview {
            subview.frame = self.bounds
        }
    }
}

class CustomizableActionSheet: NSObject {
    
    // MARK: - Private properties
    private static var actionSheets = [CustomizableActionSheet]()
    private static let kCornerRadius: CGFloat = 4
    private static let kMarginSide: CGFloat = 8
    private static let kMarginBottom: CGFloat = 8
    private var items: [CustomizableActionSheetItem]?
    private let maskView = UIView()
    private let itemContainerView = UIView()
    private var closeBlock: (() -> Void)?
    
    class func showInView(targetView: UIView, items: [CustomizableActionSheetItem], closeBlock: (() -> Void)? = nil) {
        // Make instance to show action sheet
        let actionSheet = CustomizableActionSheet()
        
        // Save instance to reaction until closing this sheet
        CustomizableActionSheet.actionSheets.append(actionSheet)
        
        let screenBounds = UIScreen.mainScreen().bounds
        
        // Save closeBlock
        actionSheet.closeBlock = closeBlock
        
        // mask view
        let maskViewTapGesture = UITapGestureRecognizer(target: actionSheet, action: "maskViewWasTapped")
        actionSheet.maskView.addGestureRecognizer(maskViewTapGesture)
        actionSheet.maskView.frame = screenBounds
        actionSheet.maskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        targetView.addSubview(actionSheet.maskView)
        
        // set items
        for subview in actionSheet.itemContainerView.subviews {
            subview.removeFromSuperview()
        }
        var currentPosition: CGFloat = 0
        for item in items {
            switch (item.type) {
            case .Button:
                let button = UIButton()
                button.layer.cornerRadius = CustomizableActionSheet.kCornerRadius
                button.frame = CGRectMake(
                    CustomizableActionSheet.kMarginSide,
                    currentPosition,
                    screenBounds.width - (CustomizableActionSheet.kMarginSide * 2),
                    item.height)
                button.setTitle(item.label, forState: .Normal)
                button.backgroundColor = item.backgroundColor
                button.setTitleColor(item.textColor, forState: .Normal)
                if let font = item.font {
                    button.titleLabel?.font = font
                }
                if let _ = item.selectAction {
                    button.addGestureRecognizer(UITapGestureRecognizer(target: actionSheet, action: "buttonWasTapped:"))
                }
                item.element = button
                actionSheet.itemContainerView.addSubview(button)
                currentPosition = currentPosition + item.height + CustomizableActionSheet.kMarginBottom
            case .View:
                if let view = item.view {
                    let containerView = ActionSheetItemView(frame: CGRectMake(
                        CustomizableActionSheet.kMarginSide,
                        currentPosition,
                        screenBounds.width - (CustomizableActionSheet.kMarginSide * 2),
                        item.height))
                    containerView.layer.cornerRadius = CustomizableActionSheet.kCornerRadius
                    containerView.addSubview(view)
                    view.frame = view.bounds
                    actionSheet.itemContainerView.addSubview(containerView)
                    item.element = view
                    currentPosition = currentPosition + item.height + CustomizableActionSheet.kMarginBottom
                }
            }
        }
        actionSheet.itemContainerView.frame = CGRectMake(
            0,
            screenBounds.height - currentPosition,
            screenBounds.width,
            currentPosition)
        actionSheet.items = items
        
        // Show animation
        actionSheet.maskView.alpha = 0
        targetView.addSubview(actionSheet.itemContainerView)
        let moveY = screenBounds.height - actionSheet.itemContainerView.frame.origin.y
        actionSheet.itemContainerView.transform = CGAffineTransformMakeTranslation(0, moveY)
        UIView.animateWithDuration(0.15,
            delay: 0,
            options: .CurveEaseOut,
            animations: { () -> Void in
                actionSheet.maskView.alpha = 1
                actionSheet.itemContainerView.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    func dismiss() {
        // Hide animation
        self.maskView.alpha = 1
        let moveY = UIScreen.mainScreen().bounds.height - self.itemContainerView.frame.origin.y
        UIView.animateWithDuration(0.15,
            delay: 0,
            options: .CurveEaseOut,
            animations: { () -> Void in
                self.maskView.alpha = 0
                self.itemContainerView.transform = CGAffineTransformMakeTranslation(0, moveY)
            }) { (result: Bool) -> Void in
                // Remove views
                self.itemContainerView.removeFromSuperview()
                self.maskView.removeFromSuperview()
                
                // Remove this instance
                for var i = 0, length = CustomizableActionSheet.actionSheets.count; i < length; i++ {
                    if CustomizableActionSheet.actionSheets[i] == self {
                        CustomizableActionSheet.actionSheets.removeAtIndex(i)
                        break
                    }
                }
                
                self.closeBlock?()
        }
    }
    
    // MARK: - Private methods
    
    @objc private func maskViewWasTapped() {
        self.dismiss()
    }
    
    @objc private func buttonWasTapped(sender: AnyObject) {
        guard let items = self.items else {
            return
        }
        for item in items {
            guard
                let element = item.element,
                let gestureRecognizer = sender as? UITapGestureRecognizer else {
                    continue
            }
            if element == gestureRecognizer.view {
                item.selectAction?(actoinSheet: self)
            }
        }
    }
}