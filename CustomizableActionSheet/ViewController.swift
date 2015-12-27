//
//  ViewController.swift
//  CustomizableActionSheet
//
//  Created by Ryuta Kibe on 2015/12/21.
//  Copyright © 2015年 blk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var actionSheet: CustomizableActionSheet?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func buttonShowWasTapped(sender: AnyObject) {
    var items = [CustomizableActionSheetItem]()
    
    // First view
    if let sampleView = UINib(nibName: "SampleView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as? SampleView {
      sampleView.delegate = self
      let sampleViewItem = CustomizableActionSheetItem()
      sampleViewItem.type = .View
      sampleViewItem.view = sampleView
      sampleViewItem.height = 100
      items.append(sampleViewItem)
    }
    
    // Second button
    let clearItem = CustomizableActionSheetItem()
    clearItem.type = .Button
    clearItem.label = "Clear color"
    clearItem.backgroundColor = UIColor(red: 1, green: 0.41, blue: 0.38, alpha: 1)
    clearItem.textColor = UIColor.whiteColor()
    clearItem.selectAction = { (actionSheet: CustomizableActionSheet) -> Void in
      self.view.backgroundColor = UIColor.whiteColor()
      actionSheet.dismiss()
    }
    items.append(clearItem)

    // Third button
    let closeItem = CustomizableActionSheetItem()
    closeItem.type = .Button
    closeItem.label = "Close"
    closeItem.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    closeItem.selectAction = { (actionSheet: CustomizableActionSheet) -> Void in
      actionSheet.dismiss()
    }
    items.append(closeItem)
    
    let actionSheet = CustomizableActionSheet()
    self.actionSheet = actionSheet
    actionSheet.showInView(self.view, items: items)
  }
}

extension ViewController: SampleViewDelegate {
  func setColor(color: UIColor) {
    if let actionSheet = self.actionSheet {
      actionSheet.dismiss()
    }
    self.view.backgroundColor = color
  }
}