//
//  ViewController.swift
//  TYHeightPicker
//
//  Created by Yash Thaker on 26/04/18.
//  Copyright © 2018 Yash Thaker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var displayLbl: UILabel!
    
    var heighPicker: TYHeightPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTYHeightPicker()
    }
    
    func setupTYHeightPicker() {
        heighPicker = TYHeightPicker()
        heighPicker.translatesAutoresizingMaskIntoConstraints = false
        heighPicker.delegate = self
        self.view.addSubview(heighPicker)
        
        heighPicker.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        heighPicker.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        heighPicker.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        heighPicker.heightAnchor.constraint(equalToConstant: 145).isActive = true
    }
    
}

extension ViewController: TYHeightPickerDelegate {
    
    func selectedHeight(height: CGFloat, unit: HeightUnit) {
        if unit == .CM {
            displayLbl.text = "\(Int(height)) \(unit)"
        }
        
        if unit == .Inch {
            let feet = Int(height / 12)
            let inch = Int(height) % 12
            
            if inch != 0 {
                displayLbl.text = "\(feet) feet \(inch) inch"
                
            } else  {
                displayLbl.text = "\(feet) feet"
            }
        }
    }
}


