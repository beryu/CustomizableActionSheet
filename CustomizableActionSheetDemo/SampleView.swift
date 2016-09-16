//
//  SampleView.swift
//  CustomizableActionSheet
//
//  Created by beryu on 2015/12/27.
//  Copyright © 2015年 blk. All rights reserved.
//

import UIKit

@objc protocol SampleViewDelegate {
  func setColor(color: UIColor)
}

class SampleView: UIView {
  weak var delegate: SampleViewDelegate?
  
  @IBAction func color1WasTapped() {
    self.delegate?.setColor(color: UIColor(red: 0.89, green: 0.59, blue: 0.59, alpha: 1))
  }
  
  @IBAction func color2WasTapped() {
    self.delegate?.setColor(color: UIColor(red: 0.88, green: 0.84, blue: 0.58, alpha: 1))
  }
  
  @IBAction func color3WasTapped() {
    self.delegate?.setColor(color: UIColor(red: 0.81, green: 0.89, blue: 0.58, alpha: 1))
  }
  
  @IBAction func color4WasTapped() {
    self.delegate?.setColor(color: UIColor(red: 0.58, green: 0.89, blue: 0.73, alpha: 1))
  }
  
  @IBAction func color5WasTapped() {
    self.delegate?.setColor(color: UIColor(red: 0.58, green: 0.78, blue: 0.89, alpha: 1))
  }
}
