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
  @objc public var type: CustomizableActionSheetItemType = .button
  @objc public var height: CGFloat = CustomizableActionSheetItem.kDefaultHeight
  @objc public static let kDefaultHeight: CGFloat = 44

  // Static default font that will be applied if local var font is nil 
  @objc public static var defaultFont:UIFont? = nil
  
  @objc public var font: UIFont? = nil
  
  // type = .View
  @objc public var view: UIView?

  // type = .Button
  @objc public var label: String?
  @objc public var textColor: UIColor = UIColor(red: 0, green: 0.47, blue: 1.0, alpha: 1.0)
  
  @objc public var backgroundColor: UIColor {
    set(color) {
      _backgroundColor = color
      
      if let highlightColor = color.darkerColor() {
        backgroundHighlightColor = highlightColor
      } 
    }
    get {
      return _backgroundColor
    }
  }
  
  @objc public var selectAction: ((_ actionSheet: CustomizableActionSheet) -> Void)? = nil
  
  // MARK: - Private properties
  fileprivate var element: UIView? = nil
  fileprivate var observedButton:UIButton? = nil
  
  private var _backgroundColor: UIColor       = UIColor.white
  private var backgroundHighlightColor: UIColor   = UIColor.white.darkerColor()!
  
  @objc
  public convenience init(type: CustomizableActionSheetItemType,
                          height: CGFloat = CustomizableActionSheetItem.kDefaultHeight) {
    self.init()

    self.type = type
    self.height = height
  }
  
  @objc
  public convenience init(type: CustomizableActionSheetItemType) {
    self.init()
    
    self.type = type
    self.height = CustomizableActionSheetItem.kDefaultHeight
  }
  
  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
    // Perform background color changes when highlight state change is observed
    if keyPath == "highlighted", object as? UIButton === observedButton {
      observedButton!.backgroundColor = observedButton!.isHighlighted ? self.backgroundHighlightColor : self.backgroundColor
    }
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
  private static let kMarginSide: CGFloat = 8
  private static let kMarginTop: CGFloat = 20
  private var items: [CustomizableActionSheetItem]?
  private let maskView = UIView()
  private let itemContainerView = UIView()
  private var closeBlock: (() -> Void)?

  // MARK: - Public properties

  @objc public var defaultCornerRadius: CGFloat = 4
  @objc public var itemInterval: CGFloat = 8 // vertical distance between objects
  
  @objc 
  public func showInView(_ targetView: UIView, items: [CustomizableActionSheetItem], closeBlock: (() -> Void)? = nil) {
    // Save instance to reaction until closing this sheet
    CustomizableActionSheet.actionSheets.append(self)

    let targetBounds = targetView.bounds

    // Save closeBlock
    self.closeBlock = closeBlock

    // mask view
    let maskViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(CustomizableActionSheet.maskViewWasTapped))
    self.maskView.addGestureRecognizer(maskViewTapGesture)
    self.maskView.frame = targetBounds
    self.maskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    targetView.addSubview(self.maskView)

    // set items
    for subview in self.itemContainerView.subviews {
      subview.removeFromSuperview()
    }
    var currentPosition: CGFloat = 0
    let safeAreaTop: CGFloat
    let safeAreaBottom: CGFloat
    if #available(iOS 11.0, *) {
        safeAreaTop = targetView.safeAreaInsets.top
        safeAreaBottom = targetView.safeAreaInsets.bottom
    } else {
        safeAreaTop = CustomizableActionSheet.kMarginTop
        safeAreaBottom = 0
    }
    var availableHeight = targetBounds.height - safeAreaTop - safeAreaBottom

    // Calculate height of items
    for item in items {
      availableHeight = availableHeight - item.height - self.itemInterval
    }

    for item in items {
      // Apply height of items
      if availableHeight < 0 {
        let reduceNum = min(item.height, -availableHeight)
        item.height -= reduceNum
        availableHeight += reduceNum

        if item.height <= 0 {
          availableHeight += self.itemInterval
          continue
        }
      }

      // Add views
      switch (item.type) {
      case .button:
        let button = UIButton()
        button.layer.cornerRadius = defaultCornerRadius
        button.frame = CGRect(
          x: CustomizableActionSheet.kMarginSide,
          y: currentPosition,
          width: targetBounds.width - (CustomizableActionSheet.kMarginSide * 2),
          height: item.height)
        button.setTitle(item.label, for: UIControlState())
        button.setTitleColor(item.textColor, for: UIControlState())

        // background color set, plus enable highlight observing
        button.backgroundColor = item.backgroundColor
        button.addObserver(item, forKeyPath: "highlighted", options: [.new], context: nil)
        item.observedButton = button
        
        if let font = item.font ?? CustomizableActionSheetItem.defaultFont {
          button.titleLabel?.font = font
        }
        if let _ = item.selectAction {
          button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CustomizableActionSheet.buttonWasTapped(_:))))
        }
        item.element = button
        self.itemContainerView.addSubview(button)
        currentPosition = currentPosition + item.height + self.itemInterval
      case .view:
        if let view = item.view {
          let containerView = ActionSheetItemView(frame: CGRect(
            x: CustomizableActionSheet.kMarginSide,
            y: currentPosition,
            width: targetBounds.width - (CustomizableActionSheet.kMarginSide * 2),
            height: item.height))
          containerView.layer.cornerRadius = defaultCornerRadius
          containerView.addSubview(view)
          view.frame = view.bounds
          self.itemContainerView.addSubview(containerView)
          item.element = view
          currentPosition = currentPosition + item.height + self.itemInterval
        }
      }
    }
    self.itemContainerView.frame = CGRect(
      x: 0,
      y: targetBounds.height - currentPosition - safeAreaBottom,
      width: targetBounds.width,
      height: currentPosition)
    self.items = items

    // Show animation
    self.maskView.alpha = 0
    targetView.addSubview(self.itemContainerView)
    let moveY = targetBounds.height - self.itemContainerView.frame.origin.y
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

  @objc 
  public func dismiss() {
    guard let targetView = self.itemContainerView.superview else {
        return
    }

    // Hide animation
    self.maskView.alpha = 1
    let moveY = targetView.bounds.height - self.itemContainerView.frame.origin.y
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

        // be sure to remove observers for highlight effects on buttons
        if let items = self.items {
          for item in items {
            item.observedButton?.removeObserver(item, forKeyPath: "highlighted")
            item.observedButton = nil
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


// MARK: - UIColor extension - Darken

// Helpful extension to provide a darker shade of the receiver color. Allows dynamic shading of UIButtons during highlighting.
extension UIColor {
  
  /**
   * Return a darker shade of the same hue. 
   * @param shadeFactor set in bounds [0.0, 1.0]. Lower value = darker, default = 0.85
   */
  func darkerColor(shadeFactor: CGFloat = 0.85) -> UIColor? {
    var retVal: UIColor? = nil
    
    var h: CGFloat = 0.0
    var s: CGFloat = 0.0 
    var b: CGFloat = 0.0 
    var a: CGFloat = 0.0
    
    if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
      retVal = UIColor.init(hue: h, saturation: s, brightness: b * min(shadeFactor, 1.0), alpha: a)
    }
    
    return retVal
  }
}

