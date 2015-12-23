//
//  ViewController.swift
//  CustomizableActionSheet
//
//  Created by Ryuta Kibe on 2015/12/21.
//  Copyright © 2015年 blk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonShowWasTapped(sender: AnyObject) {
        var items = [CustomizableActionSheetItem]()
        let closeButton = CustomizableActionSheetItem()
        closeButton.type = .Button
        closeButton.height = 60
        closeButton.label = "Close"
        closeButton.backgroundColor = UIColor.whiteColor()
        closeButton.textColor = UIColor.redColor()
        closeButton.selectAction = { (actionSheet: CustomizableActionSheet) -> Void in
            actionSheet.dismiss()
        }
        items.append(closeButton)
        CustomizableActionSheet.showInView(self.view, items: items)
    }
    
}

