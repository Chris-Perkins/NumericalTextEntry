//
//  ViewController.swift
//  NumericalTextField
//
//  Created by chrisfromtemporaryid@gmail.com on 07/07/2018.
//  Copyright (c) 2018 chrisfromtemporaryid@gmail.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let shrinkText = "Shrink"
    let growText = "Grow"

    @IBOutlet var smallHeight: NSLayoutConstraint!
    @IBOutlet var bigHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func shrinkPress(_ sender: UIButton) {
        if sender.titleLabel?.text == shrinkText {
            bigHeight.isActive = false
            smallHeight.isActive = true
            
            sender.setTitle(growText, for: .normal)
        } else {
            smallHeight.isActive = false
            bigHeight.isActive = true
            sender.setTitle(shrinkText, for: .normal)
        }
    }
}

