//
//  ViewController.swift
//  CustomizableActionSheet
//
//  Created by Ryuta Kibe on 2015/12/21.
//  Copyright © 2015年 blk. All rights reserved.
//

import UIKit
import CustomizableActionSheet

class ViewController: UIViewController {

  var actionSheet: CustomizableActionSheet?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func buttonShowWasTapped() {
    var items = [CustomizableActionSheetItem]()

    // First view
    if let sampleView = UINib(nibName: "SampleView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? SampleView {
      sampleView.delegate = self
      let sampleViewItem = CustomizableActionSheetItem(type: .view, height: 100)
      sampleViewItem.view = sampleView
      items.append(sampleViewItem)
    }

    // Second button
    let clearItem = CustomizableActionSheetItem(type: .button)
    clearItem.label = "Clear color"
    clearItem.backgroundColor = UIColor(red: 1, green: 0.41, blue: 0.38, alpha: 1)
    clearItem.textColor = UIColor.white
    clearItem.selectAction = { (actionSheet: CustomizableActionSheet) -> Void in
      self.view.backgroundColor = UIColor.white
      actionSheet.dismiss()
    }
    items.append(clearItem)

    // Third button
    let closeItem = CustomizableActionSheetItem(type: .button)
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
