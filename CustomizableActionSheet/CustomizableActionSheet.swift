//
//  CustomizableActionSheet.swift
//  CustomizableActionSheet
//
//  Created by Ryuta Kibe on 2015/12/22.
//  Copyright 2015 blk. All rights reserved.
//

import UIKit

@objc public enum CustomizableActionSheetItemType: Int {
  case button
  case view
}

// Can't define CustomizableActionSheetItem as struct because Obj-C can't see struct definition.
public class CustomizableActionSheetItem: NSObject {

  // MARK: - Public properties
  public var type: CustomizableActionSheetItemType = .button
  public var height: CGFloat = 44

  // type = .View
  public var view: UIView?

  // type = .Button
  public var label: String?
  public var textColor: UIColor = UIColor(red: 0, green: 0.47, blue: 1.0, alpha: 1.0)
  public var backgroundColor: UIColor = UIColor.white
  public var font: UIFont? = nil
  public var selectAction: ((_ actionSheet: CustomizableActionSheet) -> Void)? = nil

  // MARK: - Private properties
  fileprivate var element: UIView? = nil

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
    super.init(frame: CGRect.zero)
    self.setting()
  }

  func setting() {
    self.clipsToBounds = true
  }

  override func addSubview(_ view: UIView) {
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

public class CustomizableActionSheet: NSObject {

  // MARK: - Private properties

  private static var actionSheets = [CustomizableActionSheet]()
  private static let kCornerRadius: CGFloat = 4
  private static let kMarginSide: CGFloat = 8
  private static let kMarginBottom: CGFloat = 8
  private static let kMarginTop: CGFloat = 20
  private var items: [CustomizableActionSheetItem]?
  private let maskView = UIView()
  private let itemContainerView = UIView()
  private var closeBlock: (() -> Void)?

  // MARK: - Public properties

  public func showInView(_ targetView: UIView, items: [CustomizableActionSheetItem], closeBlock: (() -> Void)? = nil) {
    // Save instance to reaction until closing this sheet
    CustomizableActionSheet.actionSheets.append(self)

    let screenBounds = UIScreen.main.bounds

    // Save closeBlock
    self.closeBlock = closeBlock

    // mask view
    let maskViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(CustomizableActionSheet.maskViewWasTapped))
    self.maskView.addGestureRecognizer(maskViewTapGesture)
    self.maskView.frame = screenBounds
    self.maskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    targetView.addSubview(self.maskView)

    // set items
    for subview in self.itemContainerView.subviews {
      subview.removeFromSuperview()
    }
    var currentPosition: CGFloat = 0
    var availableHeight = screenBounds.height - CustomizableActionSheet.kMarginTop

    // Calculate height of items
    for item in items {
      availableHeight = availableHeight - item.height - CustomizableActionSheet.kMarginBottom
    }

    for item in items {
      // Apply height of items
      if availableHeight < 0 {
        let reduceNum = min(item.height, -availableHeight)
        item.height -= reduceNum
        availableHeight += reduceNum

        if item.height <= 0 {
          availableHeight += CustomizableActionSheet.kMarginBottom
          continue
        }
      }

      // Add views
      switch (item.type) {
      case .button:
        let button = UIButton()
        button.layer.cornerRadius = CustomizableActionSheet.kCornerRadius
        button.frame = CGRect(
          x: CustomizableActionSheet.kMarginSide,
          y: currentPosition,
          width: screenBounds.width - (CustomizableActionSheet.kMarginSide * 2),
          height: item.height)
        button.setTitle(item.label, for: UIControlState())
        button.backgroundColor = item.backgroundColor
        button.setTitleColor(item.textColor, for: UIControlState())
        if let font = item.font {
          button.titleLabel?.font = font
        }
        if let _ = item.selectAction {
          button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CustomizableActionSheet.buttonWasTapped(_:))))
        }
        item.element = button
        self.itemContainerView.addSubview(button)
        currentPosition = currentPosition + item.height + CustomizableActionSheet.kMarginBottom
      case .view:
        if let view = item.view {
          let containerView = ActionSheetItemView(frame: CGRect(
            x: CustomizableActionSheet.kMarginSide,
            y: currentPosition,
            width: screenBounds.width - (CustomizableActionSheet.kMarginSide * 2),
            height: item.height))
          containerView.layer.cornerRadius = CustomizableActionSheet.kCornerRadius
          containerView.addSubview(view)
          view.frame = view.bounds
          self.itemContainerView.addSubview(containerView)
          item.element = view
          currentPosition = currentPosition + item.height + CustomizableActionSheet.kMarginBottom
        }
      }
    }
    self.itemContainerView.frame = CGRect(
      x: 0,
      y: screenBounds.height - currentPosition,
      width: screenBounds.width,
      height: currentPosition)
    self.items = items

    // Show animation
    self.maskView.alpha = 0
    targetView.addSubview(self.itemContainerView)
    let moveY = screenBounds.height - self.itemContainerView.frame.origin.y
    self.itemContainerView.transform = CGAffineTransform(translationX: 0, y: moveY)
    UIView.animate(withDuration: 0.4,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: .curveEaseOut,
      animations: { () -> Void in
        self.maskView.alpha = 1
        self.itemContainerView.transform = CGAffineTransform.identity
      }, completion: nil)
  }

  public func dismiss() {
    // Hide animation
    self.maskView.alpha = 1
    let moveY = UIScreen.main.bounds.height - self.itemContainerView.frame.origin.y
    UIView.animate(withDuration: 0.2,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: .curveEaseOut,
      animations: { () -> Void in
        self.maskView.alpha = 0
        self.itemContainerView.transform = CGAffineTransform(translationX: 0, y: moveY)
      }) { (result: Bool) -> Void in
        // Remove views
        self.itemContainerView.removeFromSuperview()
        self.maskView.removeFromSuperview()

        // Remove this instance
        for i in 0 ..< CustomizableActionSheet.actionSheets.count {
          if CustomizableActionSheet.actionSheets[i] == self {
            CustomizableActionSheet.actionSheets.remove(at: i)
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

  @objc private func buttonWasTapped(_ sender: AnyObject) {
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
        item.selectAction?(self)
      }
    }
  }
}
